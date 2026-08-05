// ─────────────────────────────────────────────────────────────
//  Selenium E2E Test Configuration
// ─────────────────────────────────────────────────────────────

/** Base URL of the Vite dev server */
export const BASE_URL = 'http://localhost:5174';

/** Default timeout for element waits (ms) */
export const DEFAULT_TIMEOUT = 1000;

/** Dummy credentials used across tests */
export const TEST_DOCTOR = {
  name: 'Dr Test Automation',
  email: 'testdoctor@gmail.com',
  password: 'test1234',
  doctor_id: 'DOC99999',
  phone: '9876543210',
  specialization: 'Pediatrics',
};

export const TEST_PATIENT = {
  patient_id: 'PAT99999',
  name: 'Test Child',
  email: 'testpatient@gmail.com',
  password: 'test1234',
  phone: '9123456789',
};
