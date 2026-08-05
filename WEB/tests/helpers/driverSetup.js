// ─────────────────────────────────────────────────────────────
//  Selenium WebDriver Setup & Reusable Helpers
// ─────────────────────────────────────────────────────────────
import { Builder, By, until } from 'selenium-webdriver';
import chrome from 'selenium-webdriver/chrome.js';
import { DEFAULT_TIMEOUT } from '../config.js';

let driver;

/**
 * Builds (or returns an existing) Chrome WebDriver instance.
 * Selenium 4's built-in Selenium Manager auto-downloads chromedriver.
 */
export async function getDriver() {
  if (driver) return driver;

  const options = new chrome.Options();
  // ──── Run headless in CI / headless environments ────
  if (process.env.CI || process.env.HEADLESS === 'true') {
    options.addArguments('--headless=new');
  }
  options.addArguments('--no-sandbox');
  options.addArguments('--disable-dev-shm-usage');
  options.addArguments('--window-size=1440,900');

  driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();

  // Global implicit wait so we don't have to wait-for-element everywhere
  await driver.manage().setTimeouts({ implicit: DEFAULT_TIMEOUT });
  return driver;
}

/** Quit the browser and reset the reference. */
export async function quitDriver() {
  if (driver) {
    await driver.quit();
    driver = null;
  }
}

// ───────── Convenience helpers ─────────

/** Wait for an element to be visible, then return it. */
export async function waitFor(css, timeout = DEFAULT_TIMEOUT) {
  const d = await getDriver();
  return d.wait(until.elementLocated(By.css(css)), timeout);
}

/** Type into an input identified by CSS selector. */
export async function typeInto(css, text) {
  const el = await waitFor(css);
  await el.clear();
  await el.sendKeys(text);
}

/** Click an element identified by CSS selector. */
export async function clickOn(css) {
  const el = await waitFor(css);
  await el.click();
}

/** Small sleep helper (only use when truly needed). */
export function sleep(ms = 100) {
  return new Promise((r) => setTimeout(r, ms));
}
