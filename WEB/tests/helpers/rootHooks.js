// ─────────────────────────────────────────────────────────────
//  Mocha Root Hooks — runs ONCE before/after ALL test files
//  Manages Vite server + Selenium driver lifecycle
// ─────────────────────────────────────────────────────────────
import { spawn } from 'child_process';
import { Builder } from 'selenium-webdriver';
import chrome from 'selenium-webdriver/chrome.js';
import { setSharedDriver, clearSharedDriver } from './sharedDriver.js';

let viteProcess = null;

async function waitForVite(url, retries = 30, delay = 500) {
  const { default: fetch } = await import('node-fetch').catch(() => ({ default: null }));
  if (!fetch) {
    // Fallback: just wait 3 seconds
    await new Promise(r => setTimeout(r, 3000));
    return;
  }
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(url);
      if (res.ok) return;
    } catch (_) {}
    await new Promise(r => setTimeout(r, delay));
  }
}

export const mochaHooks = {
  async beforeAll() {
    // 1. Start Vite dev server
    viteProcess = spawn('npx', ['vite', '--port', '5174', '--strictPort'], {
      cwd: process.cwd(),
      shell: true,
      stdio: 'pipe',
    });
    // Wait for Vite to be ready
    await new Promise(resolve => setTimeout(resolve, 4000));

    // 2. Build Chrome driver
    const options = new chrome.Options();
    options.addArguments('--headless=new');
    options.addArguments('--no-sandbox');
    options.addArguments('--disable-dev-shm-usage');
    options.addArguments('--window-size=1440,900');
    options.addArguments('--disable-gpu');
    options.addArguments('--disable-extensions');

    const driver = await new Builder()
      .forBrowser('chrome')
      .setChromeOptions(options)
      .build();

    await driver.manage().setTimeouts({ implicit: 500, pageLoad: 10000 });
    setSharedDriver(driver);
  },

  async afterAll() {
    await clearSharedDriver();
    if (viteProcess) {
      viteProcess.kill('SIGTERM');
      viteProcess = null;
    }
  },
};
