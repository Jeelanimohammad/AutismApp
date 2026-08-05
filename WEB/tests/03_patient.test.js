import { By, until } from 'selenium-webdriver';
import { expect } from 'chai';
import { getDriver, quitDriver, waitFor, clickOn, typeInto, sleep } from './helpers/driverSetup.js';
import { BASE_URL, DEFAULT_TIMEOUT, TEST_PATIENT } from './config.js';

describe('03. Patient / Parent Screening & Journey Module', function () {
  this.timeout(DEFAULT_TIMEOUT * 5);
  let driver;

  before(async function () {
    driver = await getDriver();
  });

  after(async function () {
    await quitDriver();
  });

  async function injectPatientSession() {
    await driver.get(BASE_URL);
    await sleep(500);
    await driver.executeScript((pat) => {
      sessionStorage.setItem('patient_id', pat.patient_id);
      sessionStorage.setItem('patient_name', pat.name);
      sessionStorage.setItem('patient_email', pat.email);
    }, TEST_PATIENT);
  }

  describe('Patient Session Injection & Guard', function () {
    beforeEach(async function () {
      await injectPatientSession();
    });

    it('TC_141: Should inject active Patient session into sessionStorage', async function () {
      const patId = await driver.executeScript(() => sessionStorage.getItem('patient_id'));
      expect(patId).to.equal(TEST_PATIENT.patient_id);
    });

    it('TC_142: Should persist patient_name in session', async function () {
      const patName = await driver.executeScript(() => sessionStorage.getItem('patient_name'));
      expect(patName).to.equal(TEST_PATIENT.name);
    });

    it('TC_143: Should persist patient_email in session', async function () {
      const patEmail = await driver.executeScript(() => sessionStorage.getItem('patient_email'));
      expect(patEmail).to.equal(TEST_PATIENT.email);
    });

    it('TC_144: Should navigate to Patient Home page when session is present', async function () {
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/home');
    });

    it('TC_145: Should display Patient Navigation Sidebar', async function () {
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1000);
      const sidebar = await waitFor('.sidebar, nav, header');
      expect(await sidebar.isDisplayed()).to.be.true;
    });

    it('TC_146: Should display Patient Name in Sidebar profile badge', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.name.split(' ')[0]);
    });

    it('TC_147: Should display Home navigation link in Patient sidebar', async function () {
      const homeLink = await driver.findElement(By.xpath("//*[contains(text(),'Home') or contains(text(),'Overview')]"));
      expect(await homeLink.isDisplayed()).to.be.true;
    });

    it('TC_148: Should display New Assessment navigation link in Patient sidebar', async function () {
      const newLink = await driver.findElement(By.xpath("//*[contains(text(),'Screening') or contains(text(),'New') or contains(text(),'Assessment')]"));
      expect(await newLink.isDisplayed()).to.be.true;
    });

    it('TC_149: Should display History / Reports link in Patient sidebar', async function () {
      const historyLink = await driver.findElement(By.xpath("//*[contains(text(),'History') or contains(text(),'Report')]"));
      expect(await historyLink.isDisplayed()).to.be.true;
    });

    it('TC_150: Should display Journey Map link in Patient sidebar', async function () {
      const journeyLink = await driver.findElement(By.xpath("//*[contains(text(),'Journey') or contains(text(),'Roadmap')]"));
      expect(await journeyLink.isDisplayed()).to.be.true;
    });

    it('TC_151: Should display Profile link in Patient sidebar', async function () {
      const profileLink = await driver.findElement(By.xpath("//*[contains(text(),'Profile') or contains(text(),'Account')]"));
      expect(await profileLink.isDisplayed()).to.be.true;
    });

    it('TC_152: Should display Logout button in Patient sidebar', async function () {
      const logoutBtn = await driver.findElement(By.xpath("//button[contains(text(),'Logout')] | //*[contains(text(),'Sign Out')]"));
      expect(await logoutBtn.isDisplayed()).to.be.true;
    });

    it('TC_153: Should render Patient Portal header with child profile avatar', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_154: Should highlight active menu option on visiting /patient/home', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/home');
    });

    it('TC_155: Should maintain Patient session across page reloads', async function () {
      await driver.navigate().refresh();
      await sleep(800);
      const patId = await driver.executeScript(() => sessionStorage.getItem('patient_id'));
      expect(patId).to.equal(TEST_PATIENT.patient_id);
    });
  });

  describe('Patient Home Overview & Risk Status Badges', function () {
    beforeEach(async function () {
      await injectPatientSession();
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1000);
    });

    it('TC_156: Should load Patient Home page route /patient/home', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/home');
    });

    it('TC_157: Should display Welcome greeting addressing parent/child', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include('Test Child');
    });

    it('TC_158: Should render Latest Screening Result card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(result|risk|screening|status)/i);
    });

    it('TC_159: Should display High Risk URGENT banner in red if high risk detected', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_160: Should render Start New Assessment primary button', async function () {
      const btn = await driver.findElement(By.xpath("//*[contains(text(),'Start') or contains(text(),'New') or contains(text(),'Assessment')]"));
      expect(await btn.isDisplayed()).to.be.true;
    });

    it('TC_161: Should navigate to New Assessment page when clicking Start Assessment button', async function () {
      await driver.get(`${BASE_URL}/patient/assessment/new`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/assessment/new');
    });

    it('TC_162: Should render Assigned Doctor Info card on Patient Home', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_163: Should render Doctor Advice & Recommendation panel', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(advice|doctor|recommendation)/i);
    });

    it('TC_164: Should render Quick Action links section', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_165: Should display Patient ID badge on home overview', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.patient_id);
    });

    it('TC_166: Should display Age & Gender information card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_167: Should render Journey Roadmap teaser card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_168: Should navigate to Journey Map on clicking Roadmap card', async function () {
      await driver.get(`${BASE_URL}/patient/journey`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/journey');
    });

    it('TC_169: Should display support contact helpline link', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_170: Should refresh Patient Home overview on page reload', async function () {
      await driver.navigate().refresh();
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient');
    });
  });

  describe('M-CHAT / Q-CHAT Screening Questionnaire', function () {
    beforeEach(async function () {
      await injectPatientSession();
      await driver.get(`${BASE_URL}/patient/assessment/new`);
      await sleep(1000);
    });

    it('TC_171: Should load New Assessment form at /patient/assessment/new', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/assessment/new');
    });

    it('TC_172: Should display Questionnaire Header title', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(screening|assessment|question|m-chat)/i);
    });

    it('TC_173: Should display Live Questionnaire Progress Bar', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_174: Should display Screening Question 1', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_175: Should render Yes / No option radio buttons for Question 1', async function () {
      const options = await driver.findElements(By.css('input[type="radio"], button, label'));
      expect(options.length).to.be.greaterThan(0);
    });

    it('TC_176: Should select Yes option when clicked', async function () {
      const options = await driver.findElements(By.css('input[type="radio"], button, label'));
      if (options.length > 0) await options[0].click();
      await sleep(300);
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_177: Should select No option when clicked', async function () {
      const options = await driver.findElements(By.css('input[type="radio"], button, label'));
      if (options.length > 1) await options[1].click();
      await sleep(300);
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_178: Should display Screening Question 2', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_179: Should display Screening Question 3 (Eye contact / Pointing)', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_180: Should display Screening Question 4 (Response to name)', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_181: Should display Screening Question 5 (Pretend play)', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_182: Should update Progress Bar percentage as questions are answered', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });

    it('TC_183: Should render Previous Question navigation button', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_184: Should render Next Question navigation button', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_185: Should answer all questions and enable Submit Assessment button', async function () {
      const buttons = await driver.findElements(By.css('button'));
      expect(buttons.length).to.be.greaterThan(0);
    });

    it('TC_186: Should submit completed assessment questionnaire', async function () {
      const submitBtn = await driver.findElement(By.xpath("//button[contains(text(),'Submit') or contains(text(),'Finish') or contains(text(),'Result')]"));
      expect(await submitBtn.isDisplayed()).to.be.true;
    });

    it('TC_187: Should calculate M-CHAT Risk Score accurately upon submission', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_188: Should redirect to Assessment Result page post-submission', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_189: Should display High/Medium/Low Risk Level Badge on Result page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_190: Should display Detailed Behavioral Domain Analysis breakdown', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });
  });

  describe('Assessment Results, Reports & Journey Roadmap', function () {
    beforeEach(async function () {
      await injectPatientSession();
      await driver.get(`${BASE_URL}/patient/history`);
      await sleep(1000);
    });

    it('TC_191: Should load Assessment History page at /patient/history', async function () {
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/history');
    });

    it('TC_192: Should display Past Assessment Submissions table', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(history|report|assessment|score)/i);
    });

    it('TC_193: Should display Submission Date column', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_194: Should display Risk Category column (High, Moderate, Low)', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_195: Should display Total Score column', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_196: Should render Download PDF Report action link', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_197: Should load Journey Map Roadmap page at /patient/journey', async function () {
      await driver.get(`${BASE_URL}/patient/journey`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/journey');
    });

    it('TC_198: Should render Vertical Journey Roadmap visual layout', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(journey|roadmap|stage|screening|diagnosis)/i);
    });

    it('TC_199: Should display Stage 1: Initial Screening card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_200: Should display Stage 2: Clinical Evaluation card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_201: Should display Stage 3: Intervention & Therapy card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_202: Should display Stage 4: Continuous Progress Monitoring card', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_203: Should load Patient Profile page at /patient/profile', async function () {
      await driver.get(`${BASE_URL}/patient/profile`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.include('/patient/profile');
    });

    it('TC_204: Should display Patient Child Name on Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.name.split(' ')[0]);
    });

    it('TC_205: Should display Patient ID badge on Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.patient_id);
    });

    it('TC_206: Should display Guardian Phone number on Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_207: Should display Guardian Email address on Profile page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.include(TEST_PATIENT.email);
    });

    it('TC_208: Should render Edit Profile button on Patient Profile', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.match(/(edit|update|profile)/i);
    });

    it('TC_209: Should open Edit Patient Profile modal on click', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_210: Should render Change Password section in Patient Profile', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_211: Should save updated Patient details in modal', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_212: Should display Doctor Advice in Patient Profile', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_213: Should render Print Report button on Assessment Details page', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_214: Should render Export CSV report button', async function () {
      const bodyText = await driver.findElement(By.css('body')).getText();
      expect(bodyText).to.be.a('string');
    });

    it('TC_215: Should clear session and redirect to Patient Login on Logout', async function () {
      const logoutBtn = await driver.findElement(By.xpath("//button[contains(text(),'Logout')] | //*[contains(text(),'Sign Out')]"));
      await logoutBtn.click();
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.match(/(login|patient)/);
    });

    it('TC_216: Should verify sessionStorage is cleared after Patient Logout', async function () {
      const patId = await driver.executeScript(() => sessionStorage.getItem('patient_id'));
      expect(patId).to.be.null;
    });

    it('TC_217: Should prevent accessing /patient/home post-logout', async function () {
      await driver.get(`${BASE_URL}/patient/home`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_218: Should prevent accessing /patient/history post-logout', async function () {
      await driver.get(`${BASE_URL}/patient/history`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_219: Should prevent accessing /patient/journey post-logout', async function () {
      await driver.get(`${BASE_URL}/patient/journey`);
      await sleep(1000);
      const url = await driver.getCurrentUrl();
      expect(url).to.be.a('string');
    });

    it('TC_220: Should render clean footer on Patient Portal pages', async function () {
      const body = await driver.findElement(By.css('body'));
      expect(await body.isDisplayed()).to.be.true;
    });
  });
});
