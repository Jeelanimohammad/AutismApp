import { useNavigate } from 'react-router-dom';
import { Stethoscope, Users, Brain, HeartPulse, ArrowRight, Shield } from 'lucide-react';

export default function RoleSelection() {
  const navigate = useNavigate();

  return (
    <div className="page-center" style={{ flexDirection: 'column', gap: 0 }}>
      {/* HERO */}
      <div className="animate-fade" style={{ textAlign: 'center', marginBottom: 56 }}>
        {/* Logo mark */}
        <div style={{
          width: 96, height: 96, borderRadius: 28, margin: '0 auto 24px',
          background: 'linear-gradient(135deg, #1D4ED8, #16A34A)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 0 0 16px rgba(29,78,216,0.1), 0 12px 40px rgba(29,78,216,0.45)',
          position: 'relative',
        }}>
          <Brain size={44} color="white" />
          {/* Pulse ring */}
          <div style={{
            position: 'absolute', inset: -12,
            borderRadius: 40,
            border: '1px solid rgba(29,78,216,0.4)',
            animation: 'pulse 2.5s ease-in-out infinite',
          }} />
        </div>

        <h1 style={{
          fontSize: 52, fontWeight: 900, lineHeight: 1.1,
          marginBottom: 12, letterSpacing: -1,
        }}>
          <span className="gradient-text">Autism</span>
        </h1>
        <p style={{ fontSize: 18, color: 'var(--text-secondary)', fontWeight: 500, marginBottom: 20, maxWidth: 380, margin: '0 auto 20px' }}>
          Early Autism Screening &amp; Clinical Assessment Platform
        </p>
        <div style={{ display: 'flex', gap: 10, justifyContent: 'center', flexWrap: 'wrap' }}>
          <span className="badge badge-purple" style={{ fontSize: 12, padding: '6px 14px' }}>
            <Shield size={12} /> Saveetha Network
          </span>
          <span className="badge badge-cyan" style={{ fontSize: 12, padding: '6px 14px' }}>
            <HeartPulse size={12} /> AI-Powered Screening
          </span>
        </div>
      </div>

      {/* ROLE CARDS */}
      <div className="animate-scale" style={{
        display: 'grid', gridTemplateColumns: '1fr 1fr',
        gap: 20, maxWidth: 580, width: '100%',
      }}>
        {/* Doctor Card */}
        <div className="role-card" onClick={() => navigate('/doctor/login')}
          style={{ '--hover-color': 'rgba(16,185,129,0.5)' }}>
          {/* Glow circle bg */}
          <div style={{
            position: 'absolute', width: 160, height: 160,
            borderRadius: '50%', top: -40, right: -40,
            background: 'radial-gradient(circle, rgba(16,185,129,0.15), transparent)',
            pointerEvents: 'none',
          }} />

          <div className="role-icon" style={{
            background: 'linear-gradient(135deg, #1D4ED8, #2563EB)',
            boxShadow: '0 8px 28px rgba(29,78,216,0.5)',
          }}>
            <Stethoscope size={40} color="white" />
          </div>

          <div>
            <div style={{ fontSize: 22, fontWeight: 900, color: 'var(--text-primary)', marginBottom: 4 }}>Doctor</div>
            <div style={{ fontSize: 13, color: 'var(--text-secondary)', fontWeight: 500 }}>Clinical Dashboard</div>
          </div>

          <div className="badge badge-green" style={{ marginTop: -4 }}>Professional Access</div>

          <div style={{
            display: 'flex', alignItems: 'center', gap: 6,
            fontSize: 13, fontWeight: 700, color: '#93C5FD',
          }}>
            Sign In <ArrowRight size={14} />
          </div>
        </div>

        {/* Parent Card */}
        <div className="role-card" onClick={() => navigate('/patient/login')}>
          <div style={{
            position: 'absolute', width: 160, height: 160,
            borderRadius: '50%', top: -40, right: -40,
            background: 'radial-gradient(circle, rgba(22,163,74,0.15), transparent)',
            pointerEvents: 'none',
          }} />

          <div className="role-icon" style={{
            background: 'linear-gradient(135deg, #16A34A, #15803D)',
            boxShadow: '0 8px 28px rgba(22,163,74,0.5)',
          }}>
            <Users size={40} color="white" />
          </div>

          <div>
            <div style={{ fontSize: 22, fontWeight: 900, color: 'var(--text-primary)', marginBottom: 4 }}>Parent</div>
            <div style={{ fontSize: 13, color: 'var(--text-secondary)', fontWeight: 500 }}>Patient Portal</div>
          </div>

          <div className="badge badge-green" style={{ marginTop: -4 }}>Family Access</div>

          <div style={{
            display: 'flex', alignItems: 'center', gap: 6,
            fontSize: 13, fontWeight: 700, color: '#86EFAC',
          }}>
            Sign In <ArrowRight size={14} />
          </div>
        </div>
      </div>

      <p style={{ marginTop: 36, fontSize: 12, color: 'var(--text-muted)', fontWeight: 500, letterSpacing: 0.3 }}>
        Authorized clinical use only · All data is encrypted &amp; secure
      </p>

      <style>{`
        @keyframes pulse {
          0%,100% { opacity:1; transform: scale(1); }
          50% { opacity:0.5; transform: scale(1.08); }
        }
      `}</style>
    </div>
  );
}
