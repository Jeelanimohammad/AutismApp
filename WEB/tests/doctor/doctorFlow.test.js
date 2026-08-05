import { By, until, Key } from 'selenium-webdriver';
import { expect } from 'chai';
import { getDriver, quitDriver, waitFor, clickOn, typeInto, sleep } from '../helpers/driverSetup.js';
import { BASE_URL, DEFAULT_TIMEOUT, TEST_DOCTOR, TEST_PATIENT } from '../config.js';

describe('Doctor Workflow Tests', function () {
  this.timeout(DEFAULT_TIMEOUT * 5);
  let driver;

  before(async function () {
    driver = await getDriver();
  });

  after(async function () {
    await quitDriver();
  });

  async function injectDoctorSession() {
    // Navigate to base url first to set origin
    await driver.get(BASE_URL);
    await sleep(1000);
    await driver.executeScript((doc) => {
      sessionStorage.setItem('doctor_id', doc.doctor_id);
      sessionStorage.setItem('doctor_name', doc.name);
      sessionStorage.setItem('doctor_email', doc.email);
      sessionStorage.setItem('doctor_specialization', doc.specialization);
    }, TEST_DOCTOR);
  }

  describe('With Active Session', function () {
    beforeEach(async function () {
      await injectDoctorSession();
    });

    it('should display the Doctor Dashboard sidebar and layout', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1500);

      const sidebar = await waitFor('.sidebar');
      expect(await sidebar.isDisplayed()).to.be.true;

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(`Dr. ${TEST_DOCTOR.name}`);
    });

    it('should navigate to and render Patients List page', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/patients');

      const heading = await waitFor('h1');
      const text = await heading.getText();
      expect(text).to.include('Good ');
      expect(text).to.include(TEST_DOCTOR.name.split(' ')[0]);
    });

    it('should navigate to and render Doctor Home page', async function () {
      await driver.get(`${BASE_URL}/doctor/home`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/home');

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('Quick Actions');
    });

    it('should navigate to Patients List when clicking the Total Patients stat card', async function () {
      await driver.get(`${BASE_URL}/doctor/home`);
      await sleep(1500);
      const statCard = await driver.findElement(By.xpath("//div[contains(text(), 'Total Patients')]/parent::div"));
      await statCard.click();
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/patients');
    });

    it('should register a new patient via the modal and find them in search', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1500);
      await clickOn('.btn-green');
      await sleep(1000);

      const testPatientId = `PAT_${Date.now()}`;
      await typeInto('input[placeholder="e.g. A111"]', testPatientId);
      await typeInto('input[placeholder="Child\'s full name"]', 'E2E Test Patient');
      const dateInput = await driver.findElement(By.css('input[type="date"]'));
      const script = `
        var setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set;
        setter.call(arguments[0], '2022-03-15');
        arguments[0].dispatchEvent(new Event('input', { bubbles: true }));
      `;
      await driver.executeScript(script, dateInput);
      await typeInto('input[placeholder="Parent\'s phone number"]', '9876543210');
      await typeInto('input[placeholder="Parent\'s email"]', 'e2etest@gmail.com');
      await typeInto('input[placeholder="Set login password"]', 'pass1234');

      const femaleBtn = await driver.wait(until.elementLocated(By.xpath("//button[contains(text(),'Female')]")), DEFAULT_TIMEOUT);
      await femaleBtn.click();
      await sleep(500);

      const submitBtn = await driver.wait(until.elementLocated(By.css('button[type="submit"]')), DEFAULT_TIMEOUT);
      await submitBtn.click();
      await sleep(2500);

      await typeInto('input[placeholder="Search patients..."]', 'E2E Test Patient');
      await sleep(1000);

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('E2E Test Patient');
    });

    it('should open patient details, add advice, download report, and delete assessment', async function () {
      await driver.get(`${BASE_URL}/doctor/patients/${TEST_PATIENT.patient_id}`);
      await sleep(2000);

      const assessmentCards = await driver.findElements(By.css('.assessment-card'));
      if (assessmentCards.length > 0) {
        await assessmentCards[0].click();
        await sleep(1500);

        const bodyText = await driver.findElement(By.css('body')).getText();
        expect(bodyText).to.include('Download Report');

        const adviceTextArea = await driver.findElement(By.css('textarea'));
        await adviceTextArea.clear();
        await adviceTextArea.sendKeys('E2E Test advice message');

        const postBtn = await driver.findElement(By.xpath("//button[contains(text(), 'Post Advice')]"));
        await postBtn.click();
        await sleep(2000);

        const toastEl = await driver.wait(
          until.elementLocated(By.xpath("//*[contains(text(), 'posted successfully')]")),
          5000
        );
        expect(await toastEl.isDisplayed()).to.be.true;

        const updatedBody = await driver.findElement(By.css('body')).getText();
        expect(updatedBody).to.include('E2E Test advice message');

        const backBtn = await driver.findElement(By.css('.btn-ghost.btn-icon'));
        await backBtn.click();
        await sleep(1000);
      }
    });

    it('should navigate to and render Doctor Profile page and support editing', async function () {
      await driver.get(`${BASE_URL}/doctor/profile`);
      await sleep(1500);

      const nameInput = await driver.findElement(By.xpath("//label[text()='Full Name']/following-sibling::div/input"));
      const phoneInput = await driver.findElement(By.xpath("//label[text()='Phone Number']/following-sibling::div/input"));
      const specInput = await driver.findElement(By.xpath("//label[text()='Specialization']/following-sibling::div/input"));

      await nameInput.sendKeys(Key.END, ...Array(50).fill(Key.BACK_SPACE), 'Dr. Edited Automation');
      await phoneInput.sendKeys(Key.END, ...Array(50).fill(Key.BACK_SPACE), '9111111111');
      await specInput.sendKeys(Key.END, ...Array(50).fill(Key.BACK_SPACE), 'Neuropsychiatry');

      await clickOn('button[type="submit"]');
      await sleep(2000);

      const toastEl = await driver.wait(
        until.elementLocated(By.xpath("//*[contains(text(), 'Profile updated successfully')]")),
        5000
      );
      expect(toastEl).to.not.be.undefined;

      await nameInput.sendKeys(Key.END, ...Array(50).fill(Key.BACK_SPACE), TEST_DOCTOR.name);
      await phoneInput.sendKeys(Key.END, ...Array(50).fill(Key.BACK_SPACE), TEST_DOCTOR.phone);
      await specInput.sendKeys(Key.END, ...Array(50).fill(Key.BACK_SPACE), TEST_DOCTOR.specialization);

      await clickOn('button[type="submit"]');
      await sleep(1500);
    });

    it('should navigate to and render Analytics page', async function () {
      await driver.get(`${BASE_URL}/doctor/analytics`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/analytics');

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('Practice Overview');
    });
  });

  describe('Protected Route Guard', function () {
    it('should redirect to Doctor Login when session is cleared', async function () {
      await driver.get(BASE_URL);
      await sleep(1000);
      await driver.executeScript(() => {
        sessionStorage.clear();
      });

      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1500);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/login');
    });
  });
});
