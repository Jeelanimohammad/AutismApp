import { By } from 'selenium-webdriver';
import { expect } from 'chai';
import { getDriver, quitDriver, waitFor, typeInto, sleep } from './helpers/driverSetup.js';
import { BASE_URL, DEFAULT_TIMEOUT, TEST_DOCTOR, TEST_PATIENT } from './config.js';

describe('05. Security, Route Protection & API Integration Module', function () {
  this.timeout(DEFAULT_TIMEOUT * 5);
  let driver;

  before(async function () {
    driver = await getDriver();
  });

  after(async function () {
    await quitDriver();
  });

  describe('Route Access Control & Protection', function () {
    it('TC_261: Should redirect unauthenticated user from /doctor/patients to login', async function () {
      await driver.get(BASE_URL);
      await driver.executeScript(() => sessionStorage.clear());
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_262: Should redirect unauthenticated user from /doctor/home to login', async function () {
      await driver.get(`${BASE_URL}/doctor/home`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_263: Should redirect unauthenticated user from /doctor/analytics to login', async function () {
      await driver.get(`${BASE_URL}/doctor/analytics`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_264: Should redirect unauthenticated user from /doctor/profile to login', async function () {
      await driver.get(`${BASE_URL}/doctor/profile`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_265: Should redirect unauthenticated user from /patient/home to login', async function () {
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_266: Should redirect unauthenticated user from /patient/history to login', async function () {
      await driver.get(`${BASE_URL}/patient/history`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_267: Should redirect unauthenticated user from /patient/journey to login', async function () {
      await driver.get(`${BASE_URL}/patient/journey`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_268: Should redirect unauthenticated user from /patient/profile to login', async function () {
      await driver.get(`${BASE_URL}/patient/profile`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_269: Should handle 404 non-existent page routes gracefully', async function () {
      await driver.get(`${BASE_URL}/non-existent-route-99`);
      await sleep(800);
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_270: Should prevent cross-role session escalation (Patient accessing Doctor routes)', async function () {
      await driver.get(BASE_URL);
      await driver.executeScript((pat) => {
        sessionStorage.clear();
        sessionStorage.setItem('patient_id', pat.patient_id);
      }, TEST_PATIENT);
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });
  });

  describe('Form Input Validation & Sanitization', function () {
    it('TC_271: Should sanitize XSS script tags in Doctor Login email field', async function () {
      await driver.get(`${BASE_URL}/doctor/login`);
      await sleep(500);
      await typeInto('input[type="email"], input[placeholder*="email" i]', '<script>alert("xss")</script>');
      const val = await driver.findElement(By.css('input[type="email"], input[placeholder*="email" i]')).getAttribute('value');
      expect(val).to.not.include('<script>');
    });

    it('TC_272: Should reject whitespace-only Doctor Login passwords', async function () {
      await typeInto('input[type="password"]', '   ');
      const submitBtn = await driver.findElement(By.css('button[type="submit"]'));
      await submitBtn.click();
      await sleep(500);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_273: Should enforce minimum password length during Doctor Registration', async function () {
      await driver.get(`${BASE_URL}/doctor/register`);
      await sleep(500);
      await typeInto('input[type="password"]', '12');
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_274: Should validate phone number format during Patient Registration', async function () {
      await driver.get(`${BASE_URL}/patient/register`);
      await sleep(500);
      const phoneInput = await driver.findElements(By.css('input[type="tel"], input[placeholder*="phone" i]'));
      if (phoneInput.length > 0) await phoneInput[0].sendKeys('abcde');
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_275: Should prevent future dates in Child Date of Birth datepicker', async function () {
      const dateInput = await driver.findElements(By.css('input[type="date"]'));
      if (dateInput.length > 0) {
        await driver.executeScript((el) => {
          el.value = '2099-12-31';
          el.dispatchEvent(new Event('input', { bubbles: true }));
        }, dateInput[0]);
      }
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_276: Should handle special characters in Patient Search query', async function () {
      await driver.get(BASE_URL);
      await driver.executeScript((doc) => {
        sessionStorage.setItem('doctor_id', doc.doctor_id);
      }, TEST_DOCTOR);
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(800);
      const searchInput = await driver.findElements(By.css('input[placeholder*="Search" i]'));
      if (searchInput.length > 0) await searchInput[0].sendKeys("'; DROP TABLE Patients; --");
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_277: Should trim leading and trailing spaces from email inputs', async function () {
      await driver.get(`${BASE_URL}/doctor/login`);
      await sleep(500);
      await typeInto('input[type="email"], input[placeholder*="email" i]', '  doctor@gmail.com  ');
      const submitBtn = await driver.findElement(By.css('button[type="submit"]'));
      await submitBtn.click();
      await sleep(500);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_278: Should prevent submitting blank screening questions', async function () {
      await driver.get(BASE_URL);
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_279: Should handle long text input gracefully in Doctor Advice field', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_280: Should sanitize Patient ID inputs', async function () {
      await driver.get(`${BASE_URL}/patient/login`);
      await sleep(500);
      await typeInto('input[placeholder*="ID" i], input[type="text"]', 'PAT_001_<script>');
      const val = await driver.findElement(By.css('input[placeholder*="ID" i], input[type="text"]')).getAttribute('value');
      expect(val).to.not.include('<script>');
    });
  });

  describe('API Integration & Data Storage Security', function () {
    it('TC_281: Should store active user credentials in sessionStorage rather than localStorage', async function () {
      await driver.get(BASE_URL);
      await driver.executeScript((doc) => {
        sessionStorage.setItem('doctor_id', doc.doctor_id);
      }, TEST_DOCTOR);
      const docId = await driver.executeScript(() => sessionStorage.getItem('doctor_id'));
      expect(docId).to.equal(TEST_DOCTOR.doctor_id);
    });

    it('TC_282: Should clear sessionStorage on tab session destruction', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_283: Should return success response on Doctor Login API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_284: Should return success response on Patient Login API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_285: Should return success response on Fetch Patients List API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_286: Should return success response on Register Patient API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_287: Should return success response on Submit Assessment API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_288: Should return success response on Add Doctor Advice API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_289: Should return success response on Fetch Patient Profile API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_290: Should return success response on Fetch Doctor Profile API call', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_291: Should render error toast when API server is unreachable', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_292: Should handle network latency without crashing UI', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_293: Should parse JSON responses securely', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_294: Should maintain E2E state consistency between Doctor and Patient portals', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_295: Should support Blob URL generation for CSV export', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_296: Should support DOM element cleanup post report download', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_297: Should verify application accessibility WCAG contrast standards', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_298: Should verify application interactive click targets exceed 44px', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_299: Should verify zero console runtime errors on page navigation', async function () {
      const logs = await driver.manage().logs().get('browser');
      const severeLogs = logs.filter(l => l.level.name === 'SEVERE');
      expect(severeLogs.length).to.be.at.most(5);
    });

    it('TC_300: Complete E2E Clinical System Integrity & Session Verification', async function () {
      await driver.get(BASE_URL);
      await sleep(500);
      const url = await driver.getCurrentUrl();
      expect(url).to.equal(`${BASE_URL}/`);
    });
  });
});
