// Dynamically resolve the backend host:
// - On local machine (localhost or 127.0.0.1), connect to local XAMPP/Apache.
// - On any other host (lab network, phone, etc.), use the known server IP.
const _host = window.location.hostname;
const _isLocal = _host === 'localhost' || _host === '127.0.0.1';
const BASE_URL = _isLocal ? `http://${_host}/autism` : 'http://172.25.85.139/autism';

async function post(endpoint, body) {
  const url = `${BASE_URL}/${endpoint}?cb=${Date.now()}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`Server error: ${res.status}`);
  return res.json();
}

async function get(endpoint) {
  const sep = endpoint.includes('?') ? '&' : '?';
  const url = `${BASE_URL}/${endpoint}${sep}cb=${Date.now()}`;
  const res = await fetch(url, { headers: { Accept: 'application/json' } });
  if (!res.ok) throw new Error(`Server error: ${res.status}`);
  return res.json();
}

export const api = {
  // Auth
  loginDoctor: (credentials) => post('doctorlogin.php', credentials),
  registerDoctor: (doctor) => post('doctorregister.php', doctor),
  loginPatient: (credentials) => post('parentlogin.php', credentials),
  registerPatient: (patient) => post('patientdetails.php', patient),
  resetPassword: (params) => post('reset_password.php', params),

  // Doctor
  getDoctorProfile: (doctorID) => get(`get_doctor_profile.php?doctor_id=${doctorID}`),
  updateDoctorProfile: (params) => post('update_doctor_profile.php', params),
  getPatientsList: (doctorID) => get(`get_patients_list.php?doctor_id=${doctorID}`),
  deletePatient: (patientID) => post(`delete_patient.php?patient_id=${encodeURIComponent(patientID)}`, { patient_id: patientID }),
  addAdvice: (advice) => post('add_advice.php', advice),

  // Patient
  getPatientProfile: (patientID) => get(`get_patient_profile.php?patient_id=${patientID}`),
  updatePatientProfile: (params) => post('update_patient_profile.php', params),
  getAssessments: (patientID) => get(`get_assessments.php?patient_id=${patientID}`),
  getAssessmentDetails: (assessmentID) => get(`get_assessment_details.php?assessment_id=${assessmentID}`),
  deleteAssessment: (assessmentID) => post(`delete_assessment.php?assessment_id=${assessmentID}`, { assessment_id: assessmentID }),

  // Assessment
  getSymptoms: (age, patientID) => post('get_symptoms_by_age.php', { age, patient_id: patientID }),
  submitResponses: (patientID, age, responses) =>
    post('submit_symptom_responses.php', { patient_id: patientID, age, responses }),

  // Advice
  getAdvice: (patientID, assessmentID = null) => {
    let ep = `get_advice.php?patient_id=${patientID}`;
    if (assessmentID) ep += `&assessment_id=${assessmentID}`;
    return get(ep);
  },

  // Image helper
  resolveImageUrl: (imagePath) => {
    if (!imagePath) return null;
    let cleanPath = imagePath.trim();
    if (cleanPath.toLowerCase().startsWith('http')) {
      try {
        const urlObj = new URL(cleanPath);
        const baseUrlObj = new URL(BASE_URL);
        urlObj.protocol = baseUrlObj.protocol;
        urlObj.host = baseUrlObj.host;
        return urlObj.toString();
      } catch {
        return cleanPath;
      }
    }
    return `${BASE_URL}/${cleanPath.replace(/^\//, '')}`;
  },
};
