import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Lock, Stethoscope, ArrowLeft, Shield, CheckCircle, Eye, EyeOff } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';

export default function DoctorLogin() {
  const navigate = useNavigate();
  const { loginDoctor } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPass, setShowPass] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    if (!email || !password) return;
    setLoading(true);
    try {
      const res = await api.loginDoctor({ email, password });
      if (res.success && res.doctor) {
        loginDoctor(res.doctor);
        toast.success(`Welcome back, Dr. ${res.doctor.name}`);
        navigate('/doctor/patients', { replace: true });
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
            background: 'linear-gradient(135deg, #1D4ED8, #2563EB)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 8px 24px rgba(29,78,216,0.45)',
          }}>
            <Stethoscope size={32} color="white" />
          </div>
          <h1 style={{ fontSize: 28, fontWeight: 900, marginBottom: 8 }}>Doctor Portal</h1>
          <p style={{ fontSize: 15, color: 'var(--text-secondary)', fontWeight: 500 }}>Sign in to your clinical dashboard</p>
        </div>

        <div className="card" style={{ padding: '32px' }}>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            <div className="input-group">
              <label className="input-label">Email Address</label>
              <div className="input-field">
                <Mail size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type="email" placeholder="doctor@hospital.com" value={email} onChange={e => setEmail(e.target.value)} required />
              </div>
            </div>

            <div className="input-group">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                <label className="input-label" style={{ marginBottom: 0 }}>Password</label>
                <Link to="/forgot-password" style={{ fontSize: 13, fontWeight: 700, color: 'var(--blue)', textDecoration: 'none' }}>
                  Forgot password?
                </Link>
              </div>
              <div className="input-field">
                <Lock size={18} className="input-icon" style={{ color: '#10B981' }} />
                <input type={showPass ? 'text' : 'password'} placeholder="••••••••" value={password} onChange={e => setPassword(e.target.value)} required />
                <button type="button" onClick={() => setShowPass(v => !v)}
                  style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, color: 'var(--text-muted)', display: 'flex', alignItems: 'center' }}>
                  {showPass ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>
            </div>

            <button type="submit" className="btn btn-green btn-full" disabled={loading} style={{ marginTop: 8, height: 52 }}>
              {loading ? <span className="spinner" style={{ borderTopColor: 'white' }} /> : (
                <><Shield size={18} /> Secure Login</>
              )}
            </button>
          </form>

          <div style={{ marginTop: 24, textAlign: 'center', fontSize: 14 }}>
            <span style={{ color: 'var(--text-muted)' }}>Don't have an account? </span>
            <Link to="/doctor/register" style={{ color: '#34D399', fontWeight: 700, textDecoration: 'none' }}>Apply Now</Link>
          </div>
        </div>
      </div>
    </div>
  );
}
