// ─────────────────────────────────────────────────────────────
//  AUTH FLOW TESTS
//  Covers: Role Selection, Doctor Login, Patient Login,
//          Doctor Registration, Patient Registration,
//          Forgot Password page
// ─────────────────────────────────────────────────────────────
import { By, until } from 'selenium-webdriver';
import { expect } from 'chai';
import {
  getDriver, quitDriver, waitFor, typeInto, clickOn, sleep,
} from '../helpers/driverSetup.js';
import {
  BASE_URL, DEFAULT_TIMEOUT, TEST_DOCTOR, TEST_PATIENT,
} from '../config.js';

/** Navigate to a route and wait for React to finish rendering. */
async function goTo(driver, path = '') {
  await driver.get(`${BASE_URL}${path}`);
  await sleep(1500);
}

describe('Authentication Flow Tests', function () {
  this.timeout(DEFAULT_TIMEOUT * 5);
  let driver;

  before(async function () {
    driver = await getDriver();
  });

  after(async function () {
    await quitDriver();
  });

  // ────────── 1. ROLE SELECTION PAGE ──────────
  describe('Role Selection Page', function () {
    it('should load the landing page at /', async function () {
      await goTo(driver, '/');
      const body = await driver.findElement(By.css('body'));
      const text = await body.getText();
      expect(text).to.include('Autism');
    });

    it('should display Doctor and Parent role cards', async function () {
      const body = await driver.findElement(By.css('body'));
      const text = await body.getText();
      expect(text).to.include('Doctor');
      expect(text).to.include('Parent');
    });

    it('should navigate to Doctor Login when Doctor card is clicked', async function () {
      await goTo(driver, '/');
      const cards = await driver.findElements(By.css('.role-card'));
      await cards[0].click();
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/login');
    });

    it('should navigate to Patient Login when Parent card is clicked', async function () {
      await goTo(driver, '/');
      const cards = await driver.findElements(By.css('.role-card'));
      await cards[1].click();
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/login');
    });
  });

  // ────────── 2. DOCTOR LOGIN PAGE ──────────
  describe('Doctor Login Page', function () {
    it('should load the Doctor Login page with correct heading', async function () {
      await goTo(driver, '/doctor/login');
      const heading = await driver.findElement(By.css('h1'));
      const text = await heading.getText();
      expect(text).to.include('Doctor Portal');
    });

    it('should display email and password inputs', async function () {
      const emailInput = await driver.findElement(By.css('input[type="email"]'));
      const passInput = await driver.findElement(By.css('input[type="password"]'));
      expect(await emailInput.isDisplayed()).to.be.true;
      expect(await passInput.isDisplayed()).to.be.true;
    });

    it('should display the Secure Login button', async function () {
      const btn = await driver.findElement(By.css('button[type="submit"]'));
      const text = await btn.getText();
      expect(text).to.include('Secure Login');
    });

    it('should have a link to Apply Now (register)', async function () {
      const link = await driver.findElement(By.css('a[href="/doctor/register"]'));
      const text = await link.getText();
      expect(text).to.include('Apply Now');
    });

    it('should fill in email and password and click login', async function () {
      await typeInto('input[type="email"]', TEST_DOCTOR.email);
      await typeInto('input[type="password"]', TEST_DOCTOR.password);
      await clickOn('button[type="submit"]');
      await sleep(2000);
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('should have a Back button that returns to role selection', async function () {
      await goTo(driver, '/doctor/login');
      await clickOn('.btn-ghost');
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.equal(`${BASE_URL}/`);
    });

    it('should display error toast on invalid credentials', async function () {
      await goTo(driver, '/doctor/login');
      await typeInto('input[type="email"]', 'wrongdoctor@gmail.com');
      await typeInto('input[type="password"]', 'wrongpass');
      await clickOn('button[type="submit"]');
      const toastEl = await driver.wait(
        until.elementLocated(By.xpath("//*[contains(text(), 'Invalid email or password') or contains(text(), 'Connection error')]")),
        5000
      );
      expect(toastEl).to.not.be.undefined;
    });

    it('should navigate to doctor register on Apply Now click and go back', async function () {
      await goTo(driver, '/doctor/login');
      await clickOn('a[href="/doctor/register"]');
      await sleep(1000);
      expect(await driver.getCurrentUrl()).to.include('/doctor/register');
      await clickOn('.btn-ghost');
      await sleep(1000);
      expect(await driver.getCurrentUrl()).to.include('/doctor/login');
    });
  });

  // ────────── 3. PATIENT LOGIN PAGE ──────────
  describe('Patient Login Page', function () {
    it('should load the Patient Login page with correct heading', async function () {
      await goTo(driver, '/patient/login');
      const heading = await driver.findElement(By.css('h1'));
      const text = await heading.getText();
      expect(text).to.include('Patient Portal');
    });

    it('should display Patient ID and password inputs', async function () {
      const idInput = await driver.findElement(
        By.css('input[type="text"][placeholder="e.g. PAT001"]')
      );
      const passInput = await driver.findElement(By.css('input[type="password"]'));
      expect(await idInput.isDisplayed()).to.be.true;
      expect(await passInput.isDisplayed()).to.be.true;
    });

    it('should fill in Patient ID and password and click login', async function () {
      await typeInto('input[type="text"][placeholder="e.g. PAT001"]', TEST_PATIENT.patient_id);
      await typeInto('input[type="password"]', TEST_PATIENT.password);
      await clickOn('button[type="submit"]');
      await sleep(2000);
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('should have a Create Account link to /patient/register', async function () {
      await goTo(driver, '/patient/login');
      const link = await driver.findElement(By.css('a[href="/patient/register"]'));
      const text = await link.getText();
      expect(text).to.include('Create Account');
    });

    it('should display error toast on invalid credentials', async function () {
      await goTo(driver, '/patient/login');
      await typeInto('input[type="text"][placeholder="e.g. PAT001"]', 'WRONGPATID');
      await typeInto('input[type="password"]', 'wrongpass');
      await clickOn('button[type="submit"]');
      const toastEl = await driver.wait(
        until.elementLocated(By.xpath("//*[contains(text(), 'Patient not found') or contains(text(), 'Connection error')]")),
        5000
      );
      expect(toastEl).to.not.be.undefined;
    });

    it('should navigate to patient register on Create Account click and go back', async function () {
      await goTo(driver, '/patient/login');
      await clickOn('a[href="/patient/register"]');
      await sleep(1000);
      expect(await driver.getCurrentUrl()).to.include('/patient/register');
      await clickOn('.btn-ghost');
      await sleep(1000);
      expect(await driver.getCurrentUrl()).to.include('/patient/login');
    });
  });

  // ────────── 4. DOCTOR REGISTRATION PAGE ──────────
  describe('Doctor Registration Page', function () {
    it('should load the registration form with correct heading', async function () {
      await goTo(driver, '/doctor/register');
      const heading = await driver.findElement(By.css('h1'));
      const text = await heading.getText();
      expect(text).to.include('Join Network');
    });

    it('should display all required input fields', async function () {
      const nameInput = await driver.findElement(
        By.css('input[placeholder="Dr. John Doe"]')
      );
      const doctorIdInput = await driver.findElement(
        By.css('input[placeholder="e.g. DOC77521"]')
      );
      const phoneInput = await driver.findElement(
        By.css('input[placeholder="e.g. 9876543210"]')
      );
      const emailInput = await driver.findElement(
        By.css('input[placeholder="doctor@hospital.com"]')
      );
      const specInput = await driver.findElement(
        By.css('input[placeholder="e.g. Pediatrics"]')
      );
      const passInput = await driver.findElement(
        By.css('input[placeholder="At least 4 characters"]')
      );

      expect(await nameInput.isDisplayed()).to.be.true;
      expect(await doctorIdInput.isDisplayed()).to.be.true;
      expect(await phoneInput.isDisplayed()).to.be.true;
      expect(await emailInput.isDisplayed()).to.be.true;
      expect(await specInput.isDisplayed()).to.be.true;
      expect(await passInput.isDisplayed()).to.be.true;
    });

    it('should fill the entire registration form', async function () {
      await typeInto('input[placeholder="Dr. John Doe"]', TEST_DOCTOR.name);
      await typeInto('input[placeholder="e.g. DOC77521"]', TEST_DOCTOR.doctor_id);
      await typeInto('input[placeholder="e.g. 9876543210"]', TEST_DOCTOR.phone);
      await typeInto('input[placeholder="doctor@hospital.com"]', TEST_DOCTOR.email);
      await typeInto('input[placeholder="e.g. Pediatrics"]', TEST_DOCTOR.specialization);
      await typeInto('input[placeholder="At least 4 characters"]', TEST_DOCTOR.password);

      const btn = await driver.findElement(By.css('button[type="submit"]'));
      const text = await btn.getText();
      expect(text).to.include('Complete Registration');
    });

    it('should have a sex dropdown with Male/Female/Other', async function () {
      const select = await driver.findElement(By.css('select'));
      const options = await select.findElements(By.css('option'));
      const texts = await Promise.all(options.map((o) => o.getText()));
      expect(texts).to.include('Male');
      expect(texts).to.include('Female');
      expect(texts).to.include('Other');
    });

    it('should have a date of birth input', async function () {
      const dateInput = await driver.findElement(By.css('input[type="date"]'));
      expect(await dateInput.isDisplayed()).to.be.true;
    });
  });

  // ────────── 5. PATIENT REGISTRATION PAGE ──────────
  describe('Patient Registration Page', function () {
    it('should load the registration form with correct heading', async function () {
      await goTo(driver, '/patient/register');
      const heading = await driver.findElement(By.css('h1'));
      const text = await heading.getText();
      expect(text).to.include('Create Profile');
    });

    it('should display all required input fields', async function () {
      const patIdInput = await driver.findElement(
        By.css('input[placeholder="e.g. PAT001"]')
      );
      const nameInput = await driver.findElement(
        By.css('input[placeholder="Full Name"]')
      );
      const phoneInput = await driver.findElement(
        By.css('input[placeholder="e.g. 9876543210"]')
      );
      const emailInput = await driver.findElement(
        By.css('input[placeholder="parent@gmail.com"]')
      );
      const passInput = await driver.findElement(
        By.css('input[placeholder="At least 4 characters"]')
      );

      expect(await patIdInput.isDisplayed()).to.be.true;
      expect(await nameInput.isDisplayed()).to.be.true;
      expect(await phoneInput.isDisplayed()).to.be.true;
      expect(await emailInput.isDisplayed()).to.be.true;
      expect(await passInput.isDisplayed()).to.be.true;
    });

    it('should fill the entire patient registration form', async function () {
      await typeInto('input[placeholder="e.g. PAT001"]', TEST_PATIENT.patient_id);
      await typeInto('input[placeholder="Full Name"]', TEST_PATIENT.name);
      await typeInto('input[placeholder="e.g. 9876543210"]', TEST_PATIENT.phone);
      await typeInto('input[placeholder="parent@gmail.com"]', TEST_PATIENT.email);
      await typeInto('input[placeholder="At least 4 characters"]', TEST_PATIENT.password);

      const btn = await driver.findElement(By.css('button[type="submit"]'));
      const text = await btn.getText();
      expect(text).to.include('Complete Registration');
    });
  });

  // ────────── 6. FORGOT PASSWORD PAGE ──────────
  describe('Forgot Password Page', function () {
    it('should load the forgot password page', async function () {
      await goTo(driver, '/forgot-password');
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('should have email and new password inputs', async function () {
      const emailInput = await driver.findElement(By.css('input[type="email"]'));
      const passInput = await driver.findElement(By.css('input[type="password"]'));
      expect(await emailInput.isDisplayed()).to.be.true;
      expect(await passInput.isDisplayed()).to.be.true;
    });
  });
});
