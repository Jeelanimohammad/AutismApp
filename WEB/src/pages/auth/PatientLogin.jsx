import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Users, Lock, ArrowLeft, Heart, Shield, Eye, EyeOff } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';

export default function PatientLogin() {
  const navigate = useNavigate();
  const { loginPatient } = useAuth();
  const [patient_id, setPatientId] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!patient_id || !password) return;
    setLoading(true);
    try {
      const res = await api.loginPatient({ patient_id, password });
      if (res.success && res.patient_id) {
        loginPatient({
          patient_id: res.patient_id,
          name: res.name,
          age: res.age,
          patient_db_id: res.patient_db_id,
          profile_image: res.profile_image
        });
        toast.success(`Welcome back, ${res.name}`);
        navigate('/patient/home', { replace: true });
      } else {
        toast.error(res.message || 'Invalid credentials');
      }
    } catch {
      toast.error('Connection error. Please try again.');
    } finally { setLoading(false); }
  }

  return (
    <div className="page-center" style={{ flexDirection: 'column' }}>
      <div style={{ width: '100%', maxWidth: 420 }} className="animate-fade">
        <button className="btn btn-ghost btn-sm" onClick={() => navigate('/')} style={{ marginBottom: 24, gap: 6 }}>
          <ArrowLeft size={16} /> Back
        </button>

        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <div style={{
            width: 72, height: 72, borderRadius: 22, margin: '0 auto 20px',
            background: 'linear-gradient(135deg, #16A34A, #15803D)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 8px 24px rgba(22,163,74,0.45)',
          }}>
            <Heart size={32} color="white" />
          </div>
          <h1 style={{ fontSize: 28, fontWeight: 900, marginBottom: 8 }}>Patient Portal</h1>
          <p style={{ fontSize: 15, color: 'var(--text-secondary)', fontWeight: 500 }}>Access your family dashboard</p>
        </div>

        <div className="card" style={{ padding: '32px' }}>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            <div className="input-group">
              <label className="input-label">Patient ID</label>
              <div className="input-field">
                <Users size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                <input type="text" placeholder="e.g. PAT001" value={patient_id} onChange={e => setPatientId(e.target.value)} required />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Password</label>
              <div className="input-field">
                <Lock size={18} className="input-icon" style={{ color: 'var(--cyan)' }} />
                <input type={showPass ? 'text' : 'password'} placeholder="••••••••" value={password} onChange={e => setPassword(e.target.value)} required />
                <button type="button" onClick={() => setShowPass(v => !v)}
                  style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, color: 'var(--text-muted)', display: 'flex', alignItems: 'center' }}>
                  {showPass ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>
            </div>

            <button type="submit" className="btn btn-primary btn-full" disabled={loading} style={{ marginTop: 8, height: 52 }}>
              {loading ? <span className="spinner" style={{ borderTopColor: 'white' }} /> : (
                <><Shield size={18} /> Secure Login</>
              )}
            </button>
          </form>

          <div style={{ marginTop: 24, textAlign: 'center', fontSize: 14 }}>
            <span style={{ color: 'var(--text-muted)' }}>New patient? </span>
            <Link to="/patient/register" style={{ color: 'var(--blue)', fontWeight: 700, textDecoration: 'none' }}>Create Account</Link>
          </div>
        </div>
      </div>
    </div>
  );
}
