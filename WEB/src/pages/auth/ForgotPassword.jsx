import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Mail, Lock, Shield, ArrowLeft, CheckCircle, Eye, EyeOff } from 'lucide-react';
import { api } from '../../api/api';

export default function ForgotPassword() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [showPass, setShowPass] = useState(false);

  const valid = email.includes('@') && newPassword.length >= 4;

  async function handleReset(e) {
    e.preventDefault();
    if (!valid) return;
    setLoading(true); setError(''); setSuccess('');
    try {
      const res = await api.resetPassword({ email, new_password: newPassword });
      if (res.success) {
        setSuccess('Password updated successfully. You can now login.');
        setEmail(''); setNewPassword('');
      } else {
        setError(res.message || 'Failed to update password. Check email.');
      }
    } catch {
      setError('Connection error. Please try again.');
    } finally { setLoading(false); }
  }

  return (
    <div className="page-center" style={{ flexDirection: 'column' }}>
      <div style={{ width: '100%', maxWidth: 440 }} className="animate-fade">
        <button className="btn btn-ghost btn-sm" onClick={() => navigate(-1)} style={{ marginBottom: 24, gap: 6 }}>
          <ArrowLeft size={16} /> Back
        </button>

        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <h1 style={{ fontSize: 26, fontWeight: 900, color: 'var(--text-primary)', marginBottom: 6 }}>Reset Password</h1>
          <p style={{ fontSize: 14, color: 'var(--text-secondary)', fontWeight: 500 }}>Enter your email to set a new password</p>
        </div>

        <div className="card" style={{ padding: '32px 28px' }}>
          {error && (
            <div className="alert alert-error" style={{ marginBottom: 20 }}>
              <Shield size={16} />
              <span>{error}</span>
            </div>
          )}
          {success && (
            <div className="alert alert-success" style={{ marginBottom: 20 }}>
              <CheckCircle size={16} />
              <span>{success}</span>
            </div>
          )}

          <form onSubmit={handleReset} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            <div className="input-group">
              <label className="input-label">Account Email</label>
              <div className="input-field">
                <Mail size={18} className="input-icon" />
                <input type="email" placeholder="email@address.com" value={email} onChange={e => setEmail(e.target.value)} />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">New Password</label>
              <div className="input-field">
                <Lock size={18} className="input-icon" />
                <input type={showPass ? 'text' : 'password'} placeholder="At least 4 characters" value={newPassword} onChange={e => setNewPassword(e.target.value)} />
                <button type="button" onClick={() => setShowPass(v => !v)}
                  style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, color: 'var(--text-muted)', display: 'flex', alignItems: 'center' }}>
                  {showPass ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>
            </div>

            <button type="submit" className="btn btn-primary btn-full" disabled={!valid || loading} style={{ marginTop: 8, height: 52 }}>
              {loading ? <span className="spinner" style={{ borderTopColor: 'white' }} /> : 'Update Password'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
