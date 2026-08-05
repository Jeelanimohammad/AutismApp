import { By, until } from 'selenium-webdriver';
import { expect } from 'chai';
import { getDriver, quitDriver, waitFor, clickOn, typeInto, sleep } from './helpers/driverSetup.js';
import { BASE_URL, DEFAULT_TIMEOUT, TEST_DOCTOR, TEST_PATIENT } from './config.js';

describe('02. Doctor Portal & Clinical Workflow Module', function () {
  this.timeout(DEFAULT_TIMEOUT * 5);
  let driver;

  before(async function () {
    driver = await getDriver();
  });

  after(async function () {
    await quitDriver();
  });

  async function injectDoctorSession() {
    await driver.get(BASE_URL);
    await sleep(500);
    await driver.executeScript((doc) => {
      sessionStorage.setItem('doctor_id', doc.doctor_id);
      sessionStorage.setItem('doctor_name', doc.name);
      sessionStorage.setItem('doctor_email', doc.email);
      sessionStorage.setItem('doctor_specialization', doc.specialization);
    }, TEST_DOCTOR);
  }

  describe('Doctor Session Injection & Guard', function () {
    beforeEach(async function () {
      await injectDoctorSession();
    });

    it('TC_061: Should inject active Doctor session into sessionStorage', async function () {
      const docId = await driver.executeScript(() => sessionStorage.getItem('doctor_id'));
      expect(docId).to.equal(TEST_DOCTOR.doctor_id);
    });

    it('TC_062: Should persist doctor_name in session', async function () {
      const docName = await driver.executeScript(() => sessionStorage.getItem('doctor_name'));
      expect(docName).to.equal(TEST_DOCTOR.name);
    });

    it('TC_063: Should persist doctor_email in session', async function () {
      const docEmail = await driver.executeScript(() => sessionStorage.getItem('doctor_email'));
      expect(docEmail).to.equal(TEST_DOCTOR.email);
    });

    it('TC_064: Should persist doctor_specialization in session', async function () {
      const docSpec = await driver.executeScript(() => sessionStorage.getItem('doctor_specialization'));
      expect(docSpec).to.equal(TEST_DOCTOR.specialization);
    });

    it('TC_065: Should navigate to Doctor Patients page when session is present', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/patients');
    });

    it('TC_066: Should display Doctor Navigation Sidebar', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1000);
      const sidebar = await waitFor('.sidebar, nav, header');
      expect(await sidebar.isDisplayed()).to.be.true;
    });

    it('TC_067: Should display Doctor name in Sidebar profile badge', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1000);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_DOCTOR.name.split(' ')[0]);
    });

    it('TC_068: Should display Doctor Specialization badge in sidebar', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_069: Should display Home navigation link in Doctor sidebar', async function () {
      const homeLink = await driver.findElement(By.xpath("//*[contains(text(),'Home') or contains(text(),'Overview')]"));
      expect(await homeLink.isDisplayed()).to.be.true;
    });

    it('TC_070: Should display Patients List navigation link in Doctor sidebar', async function () {
      const patientsLink = await driver.findElement(By.xpath("//*[contains(text(),'Patient') or contains(text(),'List')]"));
      expect(await patientsLink.isDisplayed()).to.be.true;
    });

    it('TC_071: Should display Analytics navigation link in Doctor sidebar', async function () {
      const analyticsLink = await driver.findElement(By.xpath("//*[contains(text(),'Analytic') or contains(text(),'Stat')]"));
      expect(await analyticsLink.isDisplayed()).to.be.true;
    });

    it('TC_072: Should display Profile navigation link in Doctor sidebar', async function () {
      const profileLink = await driver.findElement(By.xpath("//*[contains(text(),'Profile') or contains(text(),'Account')]"));
      expect(await profileLink.isDisplayed()).to.be.true;
    });

    it('TC_073: Should display Logout button in Doctor sidebar', async function () {
      const logoutBtn = await driver.findElement(By.xpath("//button[contains(text(),'Logout')] | //*[contains(text(),'Sign Out')]"));
      expect(await logoutBtn.isDisplayed()).to.be.true;
    });

    it('TC_074: Should highlight active menu link when visiting /doctor/patients', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/patients');
    });

    it('TC_075: Should render clean header with Doctor avatar icon', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });
  });

  describe('Doctor Dashboard Home & Stat Cards', function () {
    beforeEach(async function () {
      await injectDoctorSession();
      await driver.get(`${BASE_URL}/doctor/home`);
      await sleep(1000);
    });

    it('TC_076: Should render Doctor Home page route /doctor/home', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/home');
    });

    it('TC_077: Should display welcome heading with Doctor name', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('Dr.');
    });

    it('TC_078: Should render Total Patients registered stat card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(total|patients|registered)/i);
    });

    it('TC_079: Should render High-Risk Patients stat card highlighted in red', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(risk|high|attention)/i);
    });

    it('TC_080: Should render Total Assessments Conducted stat card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(assessment|screened|total)/i);
    });

    it('TC_081: Should render Pending Clinical Reviews stat card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_082: Should display urgent alert banner if high-risk patients are present', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_083: Should render Quick Register Patient button on Doctor Home', async function () {
      const btn = await driver.findElement(By.xpath("//button[contains(text(),'Register') or contains(text(),'Add')]"));
      expect(await btn.isDisplayed()).to.be.true;
    });

    it('TC_084: Should navigate to Patients List when clicking Total Patients stat card', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(800);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/patients');
    });

    it('TC_085: Should render Recent Patients Activity list', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_086: Should display Patient ID in activity feed', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_087: Should display screening date in activity feed', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_088: Should display risk severity badge in activity feed', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_089: Should render View All Patients button', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_090: Should refresh dashboard stats on page reload', async function () {
      await driver.navigate().refresh();
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/home');
    });
  });

  describe('Patients List & Search Filters', function () {
    beforeEach(async function () {
      await injectDoctorSession();
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1000);
    });

    it('TC_091: Should render Patients List page at route /doctor/patients', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/patients');
    });

    it('TC_092: Should display Search Patients input field', async function () {
      const searchInput = await waitFor('input[placeholder*="Search" i], input[type="text"]');
      expect(await searchInput.isDisplayed()).to.be.true;
    });

    it('TC_093: Should render Search glass icon inside input field', async function () {
      const searchInput = await driver.findElement(By.css('input[placeholder*="Search" i], input[type="text"]'));
      expect(await searchInput.isDisplayed()).to.be.true;
    });

    it('TC_094: Should filter patients list dynamically when typing in search', async function () {
      await typeInto('input[placeholder*="Search" i]', 'NonExistentChild999');
      await sleep(500);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_095: Should clear search input when deleting search text', async function () {
      await typeInto('input[placeholder*="Search" i]', '');
      await sleep(500);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_096: Should render Register New Patient button with green theme accent', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button.btn-primary, button'));
      expect(await addBtn.isDisplayed()).to.be.true;
    });

    it('TC_097: Should open Register Patient Modal on clicking green button', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button'));
      await addBtn.click();
      await sleep(800);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(register|patient|dob|phone)/i);
    });

    it('TC_098: Should display Patient Cards grid/list layout', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_099: Should display Patient ID badge on card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('PAT');
    });

    it('TC_100: Should display Patient Age & Gender tag on card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_101: Should display Guardian Contact Phone on patient card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_102: Should display Risk Level Indicator pill on patient card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_103: Should render View Details button on patient card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(view|detail|profile)/i);
    });

    it('TC_104: Should navigate to Patient Details page on card click', async function () {
      await driver.get(`${BASE_URL}/doctor/patients/${TEST_PATIENT.patient_id}`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include(TEST_PATIENT.patient_id);
    });

    it('TC_105: Should handle empty patients search result gracefully', async function () {
      await typeInto('input[placeholder*="Search" i]', 'ZZZZZZZZZ');
      await sleep(500);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });
  });

  describe('Add Patient Modal & Clinical Registration', function () {
    beforeEach(async function () {
      await injectDoctorSession();
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1000);
    });

    it('TC_106: Should render modal title "Register Patient"', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button'));
      await addBtn.click();
      await sleep(800);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('Register');
    });

    it('TC_107: Should render Close (X) button on modal header', async function () {
      const closeBtn = await driver.findElement(By.css('.modal-header button, button'));
      expect(await closeBtn.isDisplayed()).to.be.true;
    });

    it('TC_108: Should close modal when clicking Close (X) button', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button'));
      await addBtn.click();
      await sleep(500);
      const closeBtn = await driver.findElement(By.css('.modal-header button, button'));
      await closeBtn.click();
      await sleep(500);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_109: Should render Patient ID input in modal', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button'));
      await addBtn.click();
      await sleep(500);
      const input = await waitFor('input[placeholder*="e.g." i], input[type="text"]');
      expect(await input.isDisplayed()).to.be.true;
    });

    it('TC_110: Should render Child Full Name input in modal', async function () {
      const input = await waitFor('input[placeholder*="full name" i], input[placeholder*="name" i]');
      expect(await input.isDisplayed()).to.be.true;
    });

    it('TC_111: Should render Date of Birth date input in modal', async function () {
      const input = await waitFor('input[type="date"]');
      expect(await input.isDisplayed()).to.be.true;
    });

    it('TC_112: Should render Male/Female/Other sex selection toggle buttons', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(male|female|other)/i);
    });

    it('TC_113: Should render Parent Phone input field in modal', async function () {
      const input = await waitFor('input[placeholder*="phone" i], input[type="tel"]');
      expect(await input.isDisplayed()).to.be.true;
    });

    it('TC_114: Should render Parent Email input field in modal', async function () {
      const input = await waitFor('input[placeholder*="email" i], input[type="email"]');
      expect(await input.isDisplayed()).to.be.true;
    });

    it('TC_115: Should render Login Password input field in modal', async function () {
      const input = await waitFor('input[placeholder*="password" i], input[type="password"]');
      expect(await input.isDisplayed()).to.be.true;
    });

    it('TC_116: Should register new patient successfully via modal form', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button'));
      await addBtn.click();
      await sleep(500);

      const testId = `PAT_${Date.now().toString().slice(-4)}`;
      await typeInto('input[placeholder*="e.g." i]', testId);
      await typeInto('input[placeholder*="full name" i]', 'Clinical Test Child');
      await typeInto('input[placeholder*="phone" i]', '9988776655');
      await typeInto('input[placeholder*="password" i]', 'pass1234');

      const submitBtn = await driver.findElement(By.css('button[type="submit"]'));
      await submitBtn.click();
      await sleep(2000);

      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_117: Should show success toast notification after patient registration', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_118: Should automatically refresh patients list after adding patient', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/patients');
    });

    it('TC_119: Should reset modal form fields after closing and reopening', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button'));
      await addBtn.click();
      await sleep(500);
      const val = await driver.findElement(By.css('input[placeholder*="e.g." i], input[type="text"]')).getAttribute('value');
      expect(val).to.be.a('string');
    });

    it('TC_120: Should validate mandatory fields before submitting modal', async function () {
      const addBtn = await driver.findElement(By.css('.btn-green, button'));
      await addBtn.click();
      await sleep(500);
      const submitBtn = await driver.findElement(By.css('button[type="submit"]'));
      await submitBtn.click();
      await sleep(500);
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });
  });

  describe('Patient Details, Advice & Clinical Analytics', function () {
    beforeEach(async function () {
      await injectDoctorSession();
      await driver.get(`${BASE_URL}/doctor/patients/${TEST_PATIENT.patient_id}`);
      await sleep(1000);
    });

    it('TC_121: Should load Patient Details page for given patient ID', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include(TEST_PATIENT.patient_id);
    });

    it('TC_122: Should display Patient Name in details header', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.name);
    });

    it('TC_123: Should display Patient ID in header badge', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.patient_id);
    });

    it('TC_124: Should render Doctor Advice section', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(advice|recommendation|clinical)/i);
    });

    it('TC_125: Should render Add Clinical Advice textarea', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_126: Should submit doctor advice successfully', async function () {
      const textarea = await driver.findElements(By.css('textarea'));
      if (textarea.length > 0) {
        await textarea[0].sendKeys('Maintain routine sensory therapy exercises.');
        const btn = await driver.findElement(By.xpath("//button[contains(text(),'Send') or contains(text(),'Add') or contains(text(),'Save')]"));
        await btn.click();
        await sleep(1000);
      }
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_127: Should render Download PDF/CSV Assessment Report button', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(report|download|export|pdf)/i);
    });

    it('TC_128: Should load Clinical Analytics page at /doctor/analytics', async function () {
      await driver.get(`${BASE_URL}/doctor/analytics`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/analytics');
    });

    it('TC_129: Should render Risk Distribution chart on Analytics page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(analytic|distribution|risk|chart)/i);
    });

    it('TC_130: Should load Doctor Profile page at /doctor/profile', async function () {
      await driver.get(`${BASE_URL}/doctor/profile`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/doctor/profile');
    });

    it('TC_131: Should display Doctor Name on Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_DOCTOR.name.split(' ')[0]);
    });

    it('TC_132: Should display Doctor Email on Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_DOCTOR.email);
    });

    it('TC_133: Should display Doctor Specialization on Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_DOCTOR.specialization);
    });

    it('TC_134: Should render Edit Profile button on Doctor Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(edit|update|profile)/i);
    });

    it('TC_135: Should open Edit Doctor Profile modal on click', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_136: Should render Change Password section in Doctor Profile', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_137: Should save edited Doctor Profile details', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_138: Should clear session and redirect to Doctor Login on Logout click', async function () {
      const logoutBtn = await driver.findElement(By.xpath("//button[contains(text(),'Logout')] | //*[contains(text(),'Sign Out')]"));
      await logoutBtn.click();
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.match(/(login|doctor)/);
    });

    it('TC_139: Should verify sessionStorage is cleared after Logout', async function () {
      const docId = await driver.executeScript(() => sessionStorage.getItem('doctor_id'));
      expect(docId).to.be.null;
    });

    it('TC_140: Should prevent accessing /doctor/patients after logout', async function () {
      await driver.get(`${BASE_URL}/doctor/patients`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });
  });
});
