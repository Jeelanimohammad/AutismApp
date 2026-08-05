// ─────────────────────────────────────────────────────────────
//  Shared Driver Store — allows all test files to access
//  the single WebDriver instance managed by rootHooks.js
// ─────────────────────────────────────────────────────────────
let _driver = null;

export function setSharedDriver(d) { _driver = d; }
export function getSharedDriver() { return _driver; }
export async function clearSharedDriver() {
  if (_driver) {
    try { await _driver.quit(); } catch (_) {}
    _driver = null;
  }
}
