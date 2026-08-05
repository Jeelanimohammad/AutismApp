// ─────────────────────────────────────────────────────────────
//  Shared Singleton Driver for all test files
//  This module manages ONE Chrome instance for the entire session
// ─────────────────────────────────────────────────────────────
import { Builder, By, until } from 'selenium-webdriver';
import chrome from 'selenium-webdriver/chrome.js';

let _driver = null;

export async function getDriver() {
  if (_driver) return _driver;

  const options = new chrome.Options();
  options.addArguments('--headless=new');
  options.addArguments('--no-sandbox');
  options.addArguments('--disable-dev-shm-usage');
  options.addArguments('--window-size=1440,900');
  options.addArguments('--disable-gpu');
  options.addArguments('--disable-extensions');

  _driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();

  await _driver.manage().setTimeouts({ implicit: 500, pageLoad: 10000 });
  return _driver;
}

export async function quitDriver() {
  if (_driver) {
    try { await _driver.quit(); } catch (_) {}
    _driver = null;
  }
}

export async function waitFor(css, timeout = 2000) {
  const d = await getDriver();
  return d.wait(until.elementLocated(By.css(css)), timeout);
}

export async function typeInto(css, text) {
  const el = await waitFor(css);
  await el.clear();
  await el.sendKeys(text);
}

export async function clickOn(css) {
  const el = await waitFor(css);
  await el.click();
}

export function sleep(ms = 100) {
  return new Promise((r) => setTimeout(r, ms));
}
