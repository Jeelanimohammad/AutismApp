import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, User, Mail, Lock, Calendar, ArrowLeft, Shield, CheckCircle, Phone, Eye, EyeOff } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';

export default function RegisterPatient() {
  const navigate = useNavigate();
  const { loginPatient } = useAuth();
  const [form, setForm] = useState({
    patient_id: '',
    name: '',
    dob: new Date().toISOString().split('T')[0],
    sex: 'Male',
    phone: '',
    email: '',
    password: '',
  });
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);

  // Auto-calculate age from DOB
  const calculateAge = (dobString) => {
    if (!dobString) return 0;
    const today = new Date();
    const birth = new Date(dobString);
    let age = today.getFullYear() - birth.getFullYear();
    const m = today.getMonth() - birth.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--;
    return age >= 0 ? age : 0;
  };

  const childAge = calculateAge(form.dob);

  // Validations matching iOS PatientRegistrationViewModel
  const isNameValid = /^[a-zA-Z\s]+$/.test(form.name.trim());
  const isPhoneValid = form.phone.trim() === '' || /^[6-9]\d{9}$/.test(form.phone.trim());
  const lowercasedEmail = form.email.toLowerCase();
  const isEmailValid = lowercasedEmail.endsWith('@gmail.com') ||
    lowercasedEmail.endsWith('@yahoo.com') ||
    lowercasedEmail.endsWith('@saveetha.com') ||
    lowercasedEmail.endsWith('@outlook.com') ||
    lowercasedEmail.endsWith('@hotmail.com');
  const isPasswordValid = form.password.length >= 4;
  const isPatientIdValid = form.patient_id.trim().length > 0;

  const valid = isNameValid && isPhoneValid && isEmailValid && isPasswordValid && isPatientIdValid;

  async function handleRegister(e) {
    e.preventDefault();
    if (!isNameValid) { toast.error('Name must only contain letters and spaces.'); return; }
    if (!isPhoneValid) { toast.error('Phone number must be 10 digits and start with 6-9.'); return; }
    if (!isEmailValid) { toast.error('Email must end with @yahoo.com, @saveetha.com, @outlook.com, @hotmail.com, or @gmail.com'); return; }
    if (!isPasswordValid) { toast.error('Password must be at least 4 characters.'); return; }
    if (!isPatientIdValid) { toast.error('Patient ID is required.'); return; }

    setLoading(true);
    try {
      // Convert DOB from YYYY-MM-DD to DD/MM/YYYY as expected by backend
      const [y, mo, d] = form.dob.split('-');
      const dobFormatted = `${d}/${mo}/${y}`;

      const payload = {
        ...form,
        dob: dobFormatted,
        age: childAge,
      };

      const res = await api.registerPatient(payload);
      if (res.success) {
        toast.success('Registration successful!');
        // Try auto-login after registration
        const loginRes = await api.loginPatient({ patient_id: form.patient_id.trim(), password: form.password });
        if (loginRes.success && loginRes.patient_id) {
          loginPatient({
            patient_id: loginRes.patient_id,
            name: loginRes.name,
            age: loginRes.age,
            patient_db_id: loginRes.patient_db_id,
            profile_image: loginRes.profile_image,
          });
          navigate('/patient/home', { replace: true });
        } else {
          // Registration succeeded but auto-login failed — send to login screen
          navigate('/patient/login', { replace: true });
        }
      } else {
        toast.error(res.message || 'Registration failed.');
      }
    } catch {
      toast.error('Connection error. Please try again.');
    } finally { setLoading(false); }
  }

  return (
    <div className="page-center" style={{ flexDirection: 'column', padding: '40px 24px' }}>
      <div style={{ width: '100%', maxWidth: 480 }} className="animate-fade">
        <button className="btn btn-ghost btn-sm" onClick={() => navigate('/patient/login')} style={{ marginBottom: 24, gap: 6 }}>
          <ArrowLeft size={16} /> Back to Login
        </button>

        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <h1 style={{ fontSize: 26, fontWeight: 900, marginBottom: 6 }}>Create Profile</h1>
          <p style={{ fontSize: 14, color: 'var(--text-secondary)', fontWeight: 500 }}>Setup a secure family account</p>
        </div>

        <div className="card" style={{ padding: '32px 28px' }}>
          <form onSubmit={handleRegister} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {/* Identity section */}
            <div style={{ fontSize: 11, fontWeight: 800, color: 'var(--cyan)', letterSpacing: '1px', textTransform: 'uppercase', marginBottom: -8 }}>
              Child Information
            </div>

            <div className="input-group">
              <label className="input-label">Patient ID</label>
              <div className="input-field">
                <Users size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                <input type="text" placeholder="e.g. PAT001" value={form.patient_id} onChange={e => setForm({ ...form, patient_id: e.target.value })} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Child / Patient Name</label>
              <div className="input-field">
                <User size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                <input type="text" placeholder="Full Name" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} required />
              </div>
            </div>

            {/* DOB and Sex row */}
            <div style={{ display: 'flex', gap: 16 }}>
              <div className="input-group" style={{ flex: 1 }}>
                <label className="input-label">Date of Birth</label>
                <div className="input-field">
                  <Calendar size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                  <input type="date" value={form.dob} onChange={e => setForm({ ...form, dob: e.target.value })} required style={{ colorScheme: 'dark' }} />
                </div>
              </div>
              <div className="input-group" style={{ flex: 1 }}>
                <label className="input-label">Sex</label>
                <select
                  className="input-field"
                  style={{ width: '100%', padding: '0 12px', height: 46 }}
                  value={form.sex}
                  onChange={e => setForm({ ...form, sex: e.target.value })}
                >
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </div>
            </div>

            <div style={{ fontSize: 11, color: 'var(--text-secondary)', fontWeight: 700, fontFamily: 'monospace', marginTop: -8 }}>
              CALCULATED AGE: <span style={{ color: 'var(--cyan)' }}>{childAge} YEARS</span>
            </div>

            <div className="glow-divider" style={{ margin: '8px 0' }} />

            {/* Contact section */}
            <div style={{ fontSize: 11, fontWeight: 800, color: 'var(--cyan)', letterSpacing: '1px', textTransform: 'uppercase', marginBottom: -8 }}>
              Parent / Guardian Contact
            </div>

            <div className="input-group">
              <label className="input-label">Phone Number</label>
              <div className="input-field">
                <Phone size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                <input type="tel" placeholder="e.g. 9876543210" value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Parent Email</label>
              <div className="input-field">
                <Mail size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                <input type="email" placeholder="parent@gmail.com" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Secure Password</label>
              <div className="input-field">
                <Lock size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                <input type={showPass ? 'text' : 'password'} placeholder="At least 4 characters" value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} required />
                <button type="button" onClick={() => setShowPass(v => !v)}
                  style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, color: 'var(--text-muted)', display: 'flex', alignItems: 'center' }}>
                  {showPass ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>
            </div>

            <button type="submit" className="btn btn-primary btn-full" disabled={loading} style={{ marginTop: 8, height: 52 }}>
              {loading ? <span className="spinner" style={{ borderTopColor: 'white' }} /> : (
                <><CheckCircle size={18} /> Complete Registration</>
              )}
            </button>
          </form>
        </div>

        <p style={{ textAlign: 'center', marginTop: 24, fontSize: 13, color: 'var(--text-muted)' }}>
          Data is kept strictly confidential and secure.
        </p>
      </div>
    </div>
  );
}
