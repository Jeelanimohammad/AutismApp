import { By, until, Key } from 'selenium-webdriver';
import { expect } from 'chai';
import { getDriver, quitDriver, waitFor, clickOn, sleep } from '../helpers/driverSetup.js';
import { BASE_URL, DEFAULT_TIMEOUT, TEST_PATIENT } from '../config.js';

describe('Patient Workflow Tests', function () {
  this.timeout(DEFAULT_TIMEOUT * 5);
  let driver;

  before(async function () {
    driver = await getDriver();
  });

  after(async function () {
    await quitDriver();
  });

  async function injectPatientSession() {
    // Navigate to base url first to set origin
    await driver.get(BASE_URL);
    await sleep(1000);
    await driver.executeScript((pat) => {
      sessionStorage.setItem('patient_id', pat.patient_id);
      sessionStorage.setItem('patient_name', pat.name);
    }, TEST_PATIENT);
  }

  describe('With Active Session', function () {
    beforeEach(async function () {
      await injectPatientSession();
    });

    it('should display the Patient Dashboard sidebar and layout', async function () {
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1500);

      const sidebar = await waitFor('.sidebar');
      expect(await sidebar.isDisplayed()).to.be.true;

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.name);
    });

    it('should navigate to and render Patient Home page', async function () {
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/home');

      const heading = await waitFor('h1');
      const text = await heading.getText();
      expect(text).to.include(`Hello, ${TEST_PATIENT.name}`);
    });

    it('should navigate to and render Reports/Assessments History page', async function () {
      await driver.get(`${BASE_URL}/patient/assessments`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/assessments');

      const heading = await waitFor('h1');
      const text = await heading.getText();
      expect(text).to.include(`${TEST_PATIENT.name}'s History`);
    });

    it('should navigate to and render Patient Profile page', async function () {
      await driver.get(`${BASE_URL}/patient/profile`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/profile');

      const heading = await waitFor('h1');
      const text = await heading.getText();
      expect(text).to.include('Patient Profile');
    });

    it('should navigate to and render New Assessment page and support a full assessment flow', async function () {
      await driver.get(`${BASE_URL}/patient/assess`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/assess');

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('Behaviour Analysis');

      // 1. Begin Assessment
      const beginBtn = await driver.findElement(By.xpath("//button[contains(text(), 'BEGIN ANALYSIS')]"));
      await beginBtn.click();
      await sleep(1000);

      // 2. Select Age Group (<3)
      const infantGroup = await driver.findElement(By.xpath("//span[text()='Infant & Toddler']"));
      await infantGroup.click();
      await sleep(500);

      const continueBtn = await driver.findElement(By.xpath("//button[text()='Continue']"));
      await continueBtn.click();
      await sleep(1500);

      // 3. Answer YES to all loaded symptoms in the loop (Max 20 questions)
      for (let i = 0; i < 20; i++) {
        try {
          const yesBtns = await driver.findElements(By.xpath("//button[contains(text(), 'YES') and not(@disabled)]"));
          if (yesBtns.length === 0) {
            // Check if we are done (View Result button appeared)
            const viewResult = await driver.findElements(By.xpath("//button[text()='View Result']"));
            if (viewResult.length > 0) break;
            
            await sleep(1000);
            continue;
          }
          await yesBtns[0].click();
          await sleep(1000);
        } catch (e) {
          await sleep(1000);
        }
      }

      // 4. In Submission Success phase: View Result
      const viewResultBtn = await driver.wait(
        until.elementLocated(By.xpath("//button[text()='View Result']")),
        8000
      );
      await viewResultBtn.click();
      await sleep(1500);

      // 5. Verify results page and click Close
      const resultHeading = await driver.findElement(By.xpath("//h1[text()='Assessment Result']"));
      expect(await resultHeading.isDisplayed()).to.be.true;

      const closeBtn = await driver.findElement(By.xpath("//button[text()='Close']"));
      await closeBtn.click();
      await sleep(1500);

      expect(await driver.getCurrentUrl()).to.include('/patient/home');
    });

    it('should open and close the Journey Map modal on clicking View Roadmap', async function () {
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1500);

      const viewRoadmapLink = await driver.findElement(By.xpath("//span[text()='View Roadmap']"));
      await viewRoadmapLink.click();
      await sleep(1000);

      const modalTitle = await driver.findElement(By.xpath("//h2[text()='Developmental Journey']"));
      expect(await modalTitle.isDisplayed()).to.be.true;

      const closeBtn = await driver.findElement(By.xpath("//h2[text()='Developmental Journey']/following-sibling::button"));
      await closeBtn.click();
      await sleep(1000);

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.not.include('Developmental Journey');
    });

    it('should edit the patient profile and save changes', async function () {
      await driver.get(`${BASE_URL}/patient/profile`);
      await sleep(1500);

      const nameInput = await driver.findElement(By.xpath("//label[text()='Patient Name']/following-sibling::div/input"));
      const ageInput = await driver.findElement(By.xpath("//label[text()='Age (Months)']/following-sibling::div/input"));
      const phoneInput = await driver.findElement(By.xpath("//label[text()='Contact Phone']/following-sibling::div/input"));

      await driver.executeScript("arguments[0].value = 'Edited Child'; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", nameInput);
      await driver.executeScript("arguments[0].value = '48'; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", ageInput);
      await driver.executeScript("arguments[0].value = '9876543210'; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", phoneInput);

      await clickOn('button[type="submit"]');
      await sleep(2000);

      const toastEl = await driver.wait(
        until.elementLocated(By.xpath("//*[contains(text(), 'Profile updated successfully')]")),
        5000
      );
      expect(toastEl).to.not.be.undefined;

      await driver.executeScript(`arguments[0].value = '${TEST_PATIENT.name}'; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));`, nameInput);
      await driver.executeScript("arguments[0].value = '24'; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", ageInput);
      await driver.executeScript(`arguments[0].value = '${TEST_PATIENT.phone}'; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));`, phoneInput);

      await clickOn('button[type="submit"]');
      await sleep(1500);
    });

    it('should navigate to History, expand report, download it, and handle delete', async function () {
      await driver.get(`${BASE_URL}/patient/assessments`);
      await sleep(3000);

      // Look for the delete button as a proxy for assessment rows existing
      let deleteButtons = await driver.findElements(By.css('button[title="Delete report"]'));
      
      if (deleteButtons.length > 0) {
        // Click the parent row of the first delete button to expand it
        const parentRow = await driver.executeScript(
          "return arguments[0].closest('div[style*=\"cursor\"]');",
          deleteButtons[0]
        );
        
        if (parentRow) {
          await parentRow.click();
          await sleep(3000); // Wait for API to load details

          // Check if expansion worked by looking for Symptom Matrix heading
          const symptomHeaders = await driver.findElements(
            By.xpath("//*[contains(text(), 'Symptom Matrix')]")
          );
          const downloadBtns = await driver.findElements(
            By.xpath("//*[contains(text(), 'Download Report')]")
          );
          
          expect(symptomHeaders.length).to.be.greaterThan(0);
          expect(downloadBtns.length).to.be.greaterThan(0);
        }

        // Now click delete
        // Re-fetch delete buttons since DOM may have changed
        deleteButtons = await driver.findElements(By.css('button[title="Delete report"]'));
        if (deleteButtons.length > 0) {
          await deleteButtons[0].click();
          await sleep(500);

          try {
            await driver.switchTo().alert().accept();
          } catch (_) { /* app uses window.confirm which creates a native alert */ }
          await sleep(2000);

          const toastEl = await driver.wait(
            until.elementLocated(By.xpath("//*[contains(text(), 'deleted') or contains(text(), 'success') or contains(text(), 'removed')]")),
            5000
          );
          expect(toastEl).to.not.be.undefined;
        }
      }
    });
  });

  describe('Protected Route Guard', function () {
    it('should redirect to Patient Login when session is cleared', async function () {
      await driver.get(BASE_URL);
      await sleep(1000);
      await driver.executeScript(() => {
        sessionStorage.clear();
      });

      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/login');
    });
  });
});
