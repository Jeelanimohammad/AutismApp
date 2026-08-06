import { NavLink, useNavigate } from 'react-router-dom';
import { Home, ClipboardList, User, LogOut, Stethoscope, HeartPulse } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function PatientSidebar() {
  const { patient, logoutPatient } = useAuth();
  const navigate = useNavigate();

  function handleLogout() {
    logoutPatient();
    navigate('/');
  }

  const navs = [
    { to: '/patient/home', icon: Home, label: 'Home' },
    { to: '/patient/assessments', icon: ClipboardList, label: 'Reports' },
    { to: '/patient/profile', icon: User, label: 'Profile' },
  ];

  return (
    <div className="sidebar">
      {/* Top accent */}
      <div style={{ height: 3, background: 'linear-gradient(90deg, #1D4ED8, #16A34A, #EA580C)' }} />

      {/* Brand */}
      <div style={{ padding: '20px 20px 16px', borderBottom: '1px solid rgba(255,255,255,0.07)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 14 }}>
          <img src="/app-logo.png" alt="Autism Logo" style={{ width: 36, height: 36, objectFit: 'contain', flexShrink: 0 }} />
          <div className="sidebar-brand-text" style={{ fontSize: 18, fontWeight: 900, color: 'var(--text-primary)', letterSpacing: -0.3 }}>Autism</div>
          <div className="sidebar-brand-text" style={{ marginLeft: 'auto' }}>
            <HeartPulse size={14} color="var(--cyan)" />
          </div>
        </div>

        {/* Patient chip */}
        {patient && (
          <div style={{
            display: 'flex', alignItems: 'center', gap: 10,
            padding: '10px 12px',
            background: 'linear-gradient(135deg, rgba(22,163,74,0.12), rgba(29,78,216,0.08))',
            borderRadius: 14, border: '1px solid rgba(22,163,74,0.22)',
          }}>
            <div style={{
              width: 32, height: 32, borderRadius: 10,
              background: 'linear-gradient(135deg, #16A34A, #15803D)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 13, fontWeight: 900, color: 'white', flexShrink: 0,
            }}>
              {patient.name?.charAt(0).toUpperCase()}
            </div>
            <div style={{ minWidth: 0 }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-primary)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                {patient.name}
              </div>
              <div style={{ fontSize: 11, color: 'var(--green)', fontWeight: 600 }}>Patient Portal</div>
            </div>
          </div>
        )}
      </div>

      {/* Nav */}
      <div style={{ padding: '16px 12px', display: 'flex', flexDirection: 'column', gap: 4, flex: 1 }}>
        {navs.map(nav => (
          <NavLink
            key={nav.to}
            to={nav.to}
            style={({ isActive }) => ({
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '12px 14px', borderRadius: 14,
              color: isActive ? 'var(--green)' : 'var(--text-muted)',
              background: isActive
                ? 'linear-gradient(135deg, rgba(22,163,74,0.18), rgba(29,78,216,0.1))'
                : 'transparent',
              border: isActive ? '1px solid rgba(22,163,74,0.28)' : '1px solid transparent',
              fontWeight: isActive ? 700 : 500,
              textDecoration: 'none', transition: 'all 0.2s',
              fontSize: 14, position: 'relative',
              boxShadow: isActive ? '0 4px 16px rgba(22,163,74,0.18)' : 'none',
            })}
          >
            <nav.icon size={19} />
            <span className="nav-label">{nav.label}</span>
          </NavLink>
        ))}
      </div>

      {/* Logout */}
      <div style={{ padding: '12px', borderTop: '1px solid var(--border)' }}>
        <button
          className="btn btn-ghost btn-full"
          onClick={handleLogout}
          style={{ justifyContent: 'flex-start', color: 'var(--rose)', fontSize: 14, padding: '11px 14px', borderRadius: 14 }}
        >
          <LogOut size={18} /> <span className="nav-label">Logout</span>
        </button>
      </div>
    </div>
  );
}
