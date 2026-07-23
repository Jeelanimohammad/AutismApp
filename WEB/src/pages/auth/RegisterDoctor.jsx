import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Stethoscope, User, Mail, Lock, Building, ArrowLeft, Shield, CheckCircle, Phone, Calendar, Eye, EyeOff } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';

export default function RegisterDoctor() {
  const navigate = useNavigate();
  const { loginDoctor } = useAuth();
  const [form, setForm] = useState({
    name: '',
    email: '',
    password: '',
    doctor_id: '',
    phone: '',
    sex: 'Male',
    dob: new Date().toISOString().split('T')[0],
    specialization: 'Pediatrics'
  });
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);

  // Calculate age based on dob
  const calculateAge = (dobString) => {
    if (!dobString) return 0;
    const today = new Date();
    const birthDate = new Date(dobString);
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age >= 0 ? age : 0;
  };

  const doctorAge = calculateAge(form.dob);

  // Validations matching iOS app:
  const isNameValid = /^[a-zA-Z\s]+$/.test(form.name.trim());
  const isPhoneValid = /^[6-9]\d{9}$/.test(form.phone.trim());
  
  const lowercasedEmail = form.email.toLowerCase();
  const isEmailValid = lowercasedEmail.endsWith("@gmail.com") || 
                       lowercasedEmail.endsWith("@yahoo.com") || 
                       lowercasedEmail.endsWith("@saveetha.com") || 
                       lowercasedEmail.endsWith("@outlook.com") || 
                       lowercasedEmail.endsWith("@hotmail.com");

  const isPasswordValid = form.password.length >= 4;
  const isDoctorIdValid = form.doctor_id.trim().length > 0;
  const isSpecValid = form.specialization.trim().length > 0;

  const valid = isNameValid && isPhoneValid && isEmailValid && isPasswordValid && isDoctorIdValid && isSpecValid;

  async function handleRegister(e) {
    e.preventDefault();
    if (!isNameValid) { toast.error("Name must only contain letters and spaces."); return; }
    if (!isPhoneValid) { toast.error("Phone number must be 10 digits and start with 6-9."); return; }
    if (!isEmailValid) { toast.error("Email must end with @yahoo.com, @saveetha.com, @outlook.com, @hotmail.com, or @gmail.com"); return; }
    if (!isPasswordValid) { toast.error("Password must be at least 4 characters."); return; }
    if (!valid) return;

    setLoading(true);
    try {
      const res = await api.registerDoctor(form);
      if (res.success) {
        toast.success('Registration successful!');
        // Log in immediately after successful registration
        const loginRes = await api.loginDoctor({ email: form.email, password: form.password });
        if (loginRes.success && loginRes.doctor) {
          loginDoctor(loginRes.doctor);
          navigate('/doctor/patients', { replace: true });
        } else {
          toast.warning('Registration succeeded, but auto-login failed. Please log in manually.');
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
        <button className="btn btn-ghost btn-sm" onClick={() => navigate('/doctor/login')} style={{ marginBottom: 24, gap: 6 }}>
          <ArrowLeft size={16} /> Back to Login
        </button>

        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <h1 style={{ fontSize: 26, fontWeight: 900, marginBottom: 6 }}>Join Network</h1>
          <p style={{ fontSize: 14, color: 'var(--text-secondary)', fontWeight: 500 }}>Create your professional provider account</p>
        </div>

        <div className="card" style={{ padding: '32px 28px' }}>
          <form onSubmit={handleRegister} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            {/* Identity details section */}
            <div style={{ fontSize: 11, fontWeight: 800, color: '#10B981', letterSpacing: '1px', textTransform: 'uppercase', marginBottom: -8 }}>
              Identity Details
            </div>

            <div className="input-group">
              <label className="input-label">Full Name</label>
              <div className="input-field">
                <User size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type="text" placeholder="Dr. John Doe" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} required />
              </div>
            </div>

            {/* Sex and DOB Row */}
            <div style={{ display: 'flex', gap: 16 }}>
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

              <div className="input-group" style={{ flex: 1 }}>
                <label className="input-label">Date of Birth</label>
                <div className="input-field">
                  <Calendar size={18} className="input-icon" style={{ color: '#10B981' }} />
                  <input type="date" value={form.dob} onChange={e => setForm({ ...form, dob: e.target.value })} required style={{ colorScheme: 'dark' }} />
                </div>
              </div>
            </div>

            <div style={{ fontSize: 11, color: 'var(--text-secondary)', fontWeight: 700, fontFamily: 'monospace', marginTop: -8 }}>
              CALCULATED AGE: <span style={{ color: '#06B6D4' }}>{doctorAge} YEARS</span>
            </div>

            <div className="glow-divider" style={{ margin: '8px 0' }} />

            {/* Account details section */}
            <div style={{ fontSize: 11, fontWeight: 800, color: '#10B981', letterSpacing: '1px', textTransform: 'uppercase', marginBottom: -8 }}>
              Account &amp; Contact
            </div>

            <div className="input-group">
              <label className="input-label">Doctor ID</label>
              <div className="input-field">
                <Building size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type="text" placeholder="e.g. DOC77521" value={form.doctor_id} onChange={e => setForm({ ...form, doctor_id: e.target.value })} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Phone Number</label>
              <div className="input-field">
                <Phone size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type="tel" placeholder="e.g. 9876543210" value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Professional Email</label>
              <div className="input-field">
                <Mail size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type="email" placeholder="doctor@hospital.com" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Specialization</label>
              <div className="input-field">
                <Stethoscope size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type="text" placeholder="e.g. Pediatrics" value={form.specialization} onChange={e => setForm({ ...form, specialization: e.target.value })} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Secure Password</label>
              <div className="input-field">
                <Lock size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type={showPass ? 'text' : 'password'} placeholder="At least 4 characters" value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} required />
                <button type="button" onClick={() => setShowPass(v => !v)}
                  style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, color: 'var(--text-muted)', display: 'flex', alignItems: 'center' }}>
                  {showPass ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>
            </div>

            <button type="submit" className="btn btn-green btn-full" disabled={loading} style={{ marginTop: 8, height: 52 }}>
              {loading ? <span className="spinner" style={{ borderTopColor: 'white' }} /> : (
                <><CheckCircle size={18} /> Complete Registration</>
              )}
            </button>
          </form>
        </div>

        <p style={{ textAlign: 'center', marginTop: 24, fontSize: 13, color: 'var(--text-muted)' }}>
          By registering, you agree to our Terms of Service &amp; Privacy Policy.
        </p>
      </div>
    </div>
  );
}
