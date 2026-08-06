import { useNavigate } from 'react-router-dom';
import { Stethoscope, Users, Brain, ArrowRight, Shield } from 'lucide-react';

export default function RoleSelection() {
  const navigate = useNavigate();

  return (
    <div className="page-center" style={{ flexDirection: 'column', gap: 0 }}>
      {/* HERO */}
      <div className="animate-fade" style={{ textAlign: 'center', marginBottom: 56 }}>
        {/* Logo mark - Round shape with blinking and pulsing animation */}
        <div style={{ position: 'relative', width: 140, height: 140, margin: '0 auto 24px' }}>
          {/* Outer glowing pulsing aura */}
          <div style={{
            position: 'absolute',
            inset: -10,
            borderRadius: '50%',
            background: 'radial-gradient(circle, rgba(29,78,216,0.35), rgba(22,163,74,0.25), transparent)',
            border: '2px solid rgba(29,78,216,0.4)',
            animation: 'pulseGlow 2.2s ease-in-out infinite alternate',
            pointerEvents: 'none',
          }} />
          
          {/* Circular logo container with blinking effect */}
          <div style={{
            width: '100%',
            height: '100%',
            borderRadius: '50%',
            background: '#ffffff',
            padding: 12,
            display: 'flex',
            alignItems: 'center',
            justify: 'center',
            position: 'relative',
            zIndex: 1,
            overflow: 'hidden',
            boxShadow: '0 12px 36px rgba(0,0,0,0.15), 0 0 0 4px rgba(255,255,255,0.9)',
            animation: 'logoBlink 2.5s ease-in-out infinite'
          }}>
            <img 
              src="/app-logo.png" 
              alt="Autism App Logo" 
              style={{ 
                width: '100%', 
                height: '100%', 
                objectFit: 'contain',
              }} 
            />
          </div>
        </div>

        <p style={{ fontSize: 18, color: 'var(--text-secondary)', fontWeight: 500, marginBottom: 20, maxWidth: 380, margin: '12px auto 20px' }}>
          Early Autism Screening &amp; Clinical Assessment Platform
        </p>
        <div style={{ display: 'flex', gap: 10, justifyContent: 'center', flexWrap: 'wrap' }}>
          <span className="badge badge-purple" style={{ fontSize: 12, padding: '6px 14px' }}>
            <Shield size={12} /> Saveetha Network
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
