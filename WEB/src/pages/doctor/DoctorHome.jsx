import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../api/api';
import {
  Users, Activity, Clock, CheckCircle, ArrowRight,
  TrendingUp, Stethoscope, AlertCircle, Sun, Moon, Sunrise, BarChart2,
  ShieldAlert, Siren
} from 'lucide-react';


export default function DoctorHome() {
  const { doctor } = useAuth();
  const navigate = useNavigate();
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(true);

  const getGreeting = () => {
    const hr = new Date().getHours();
    if (hr < 12) return { text: 'Good Morning', icon: Sunrise, color: '#F59E0B' };
    if (hr < 17) return { text: 'Good Afternoon', icon: Sun, color: '#F97316' };
    return { text: 'Good Evening', icon: Moon, color: '#6366F1' };
  };
  const greeting = getGreeting();

  useEffect(() => {
    async function load() {
      try {
        const res = await api.getPatientsList(doctor.doctor_id);
        if (res.success) setPatients(res.patients || []);
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [doctor.doctor_id]);

  const total = patients.length;
  const pending = patients.filter(p => p.pending_reviews > 0).length;
  const reviewed = total - pending;
  const pendingPatients = patients.filter(p => p.pending_reviews > 0).slice(0, 5);
  const highRiskPatients = patients.filter(p =>
    (p.latest_result || '').toLowerCase().match(/high|severe|critical/)
  );
  const highRiskCount = highRiskPatients.length;

  return (
    <div className="animate-fade" style={{ maxWidth: 900, margin: '0 auto' }}>

      {/* Greeting */}
      <div style={{ marginBottom: 32 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
          <greeting.icon size={18} color={greeting.color} />
          <span style={{ fontSize: 13, fontWeight: 700, letterSpacing: 1.5, color: 'var(--text-secondary)' }}>
            {greeting.text.toUpperCase()}
          </span>
        </div>
        <h1 style={{ fontSize: 32, fontWeight: 900, color: 'var(--text-primary)', marginBottom: 4 }}>
          Dr. {doctor?.name?.split(' ')[0] || 'Doctor'}
        </h1>
        <p style={{ fontSize: 16, color: 'var(--text-muted)', fontWeight: 500 }}>
          {doctor?.specialization || 'Clinical Dashboard'} · {new Date().toLocaleDateString('en-IN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
        </p>
      </div>

      {/* Red High-Risk Alert Banner */}
      {!loading && highRiskCount > 0 && (
        <div style={{
          background: 'linear-gradient(135deg, #FEF2F2, #FFF1F2)',
          border: '1.5px solid #FECACA',
          borderRadius: 18, padding: '18px 24px', marginBottom: 24,
          display: 'flex', alignItems: 'center', gap: 16,
          boxShadow: '0 4px 20px rgba(220,38,38,0.08)',
          animation: 'drFadeIn 0.4s ease'
        }}>
          <div style={{
            width: 48, height: 48, borderRadius: '50%', flexShrink: 0,
            background: '#DC2626', display: 'flex', alignItems: 'center', justifyContent: 'center',
            animation: 'drRedPulse 2s ease-in-out infinite',
          }}>
            <Siren size={22} color="white" />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 900, color: '#991B1B', marginBottom: 2 }}>
              {highRiskCount} High-Risk Patient{highRiskCount > 1 ? 's' : ''} Require Immediate Attention
            </div>
            <div style={{ fontSize: 13, color: '#B91C1C', fontWeight: 500 }}>
              {highRiskPatients.slice(0, 3).map(p => p.name).join(', ')}
              {highRiskCount > 3 ? ` +${highRiskCount - 3} more` : ''} — clinical review recommended now.
            </div>
          </div>
          <button
            onClick={() => navigate('/doctor/patients')}
            style={{
              padding: '10px 18px', borderRadius: 12, border: 'none',
              background: '#DC2626', color: 'white', fontSize: 13, fontWeight: 700,
              cursor: 'pointer', whiteSpace: 'nowrap', flexShrink: 0,
              boxShadow: '0 4px 12px rgba(220,38,38,0.3)', transition: 'opacity 0.2s'
            }}
            onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
            onMouseLeave={e => e.currentTarget.style.opacity = '1'}
          >
            Review Now →
          </button>
        </div>
      )}

      {/* Stat Cards — 4 cols */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 28 }}>
        <div
          onClick={() => navigate('/doctor/patients')}
          style={{ background: 'linear-gradient(135deg, #2563EB, #3B82F6)', borderRadius: 20, padding: 22, cursor: 'pointer', color: 'white', boxShadow: '0 8px 24px rgba(37,99,235,0.3)', transition: 'transform 0.2s' }}
          onMouseEnter={e => e.currentTarget.style.transform = 'translateY(-2px)'}
          onMouseLeave={e => e.currentTarget.style.transform = 'translateY(0)'}
        >
          <div style={{ width: 40, height: 40, borderRadius: 12, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}><Users size={20} /></div>
          <div style={{ fontSize: 30, fontWeight: 900, lineHeight: 1, marginBottom: 6 }}>{loading ? '—' : total}</div>
          <div style={{ fontSize: 12, fontWeight: 600, opacity: 0.9 }}>Total Patients</div>
        </div>

        <div style={{ background: 'linear-gradient(135deg, #D97706, #F59E0B)', borderRadius: 20, padding: 22, color: 'white', boxShadow: '0 8px 24px rgba(217,119,6,0.3)' }}>
          <div style={{ width: 40, height: 40, borderRadius: 12, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}><Clock size={20} /></div>
          <div style={{ fontSize: 30, fontWeight: 900, lineHeight: 1, marginBottom: 6 }}>{loading ? '—' : pending}</div>
          <div style={{ fontSize: 12, fontWeight: 600, opacity: 0.9 }}>Pending Reviews</div>
        </div>

        <div style={{ background: 'linear-gradient(135deg, #059669, #10B981)', borderRadius: 20, padding: 22, color: 'white', boxShadow: '0 8px 24px rgba(5,150,105,0.3)' }}>
          <div style={{ width: 40, height: 40, borderRadius: 12, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14 }}><CheckCircle size={20} /></div>
          <div style={{ fontSize: 30, fontWeight: 900, lineHeight: 1, marginBottom: 6 }}>{loading ? '—' : reviewed}</div>
          <div style={{ fontSize: 12, fontWeight: 600, opacity: 0.9 }}>Reviewed</div>
        </div>

        {/* Red High-Risk card */}
        <div
          onClick={() => navigate('/doctor/patients')}
          style={{ background: 'linear-gradient(135deg, #DC2626, #EF4444)', borderRadius: 20, padding: 22, cursor: 'pointer', color: 'white', boxShadow: '0 8px 24px rgba(220,38,38,0.35)', transition: 'transform 0.2s', position: 'relative', overflow: 'hidden' }}
          onMouseEnter={e => e.currentTarget.style.transform = 'translateY(-2px)'}
          onMouseLeave={e => e.currentTarget.style.transform = 'translateY(0)'}
        >
          {!loading && highRiskCount > 0 && (
            <div style={{ position: 'absolute', top: -16, right: -16, width: 80, height: 80, borderRadius: '50%', background: 'rgba(255,255,255,0.12)', animation: 'drRedPulse 2s ease-in-out infinite' }} />
          )}
          <div style={{ width: 40, height: 40, borderRadius: 12, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 14, position: 'relative', zIndex: 1 }}><ShieldAlert size={20} /></div>
          <div style={{ fontSize: 30, fontWeight: 900, lineHeight: 1, marginBottom: 6, position: 'relative', zIndex: 1 }}>{loading ? '—' : highRiskCount}</div>
          <div style={{ fontSize: 12, fontWeight: 600, opacity: 0.9, position: 'relative', zIndex: 1 }}>High Risk</div>
        </div>
      </div>

      {/* Quick Actions + Pending List */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginBottom: 24 }}>

        <div className="card" style={{ padding: 24 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 20 }}>
            <TrendingUp size={18} color="var(--cyan)" />
            <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-primary)' }}>Quick Actions</span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[
              { label: 'View All Patients', sub: 'Manage & review patient records', icon: Users, color: '#3B82F6', bg: 'rgba(59,130,246,0.08)', action: () => navigate('/doctor/patients') },
              { label: 'Pending Reviews', sub: `${pending} assessments awaiting feedback`, icon: AlertCircle, color: '#F59E0B', bg: 'rgba(245,158,11,0.08)', action: () => navigate('/doctor/patients') },
              { label: 'High-Risk Alerts', sub: `${highRiskCount} patient${highRiskCount !== 1 ? 's' : ''} flagged for review`, icon: ShieldAlert, color: '#DC2626', bg: 'rgba(220,38,38,0.06)', action: () => navigate('/doctor/patients') },
              { label: 'Analytics', sub: 'Charts & patient insights', icon: BarChart2, color: '#8B5CF6', bg: 'rgba(139,92,246,0.08)', action: () => navigate('/doctor/analytics') },
              { label: 'My Profile', sub: 'Update credentials & specialization', icon: Stethoscope, color: '#10B981', bg: 'rgba(16,185,129,0.08)', action: () => navigate('/doctor/profile') },
            ].map(item => (
              <div
                key={item.label}
                onClick={item.action}
                style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '14px 16px', borderRadius: 14, background: item.bg, cursor: 'pointer', border: `1px solid ${item.color}22`, transition: 'all 0.2s' }}
                onMouseEnter={e => e.currentTarget.style.transform = 'translateX(4px)'}
                onMouseLeave={e => e.currentTarget.style.transform = 'translateX(0)'}
              >
                <div style={{ width: 40, height: 40, borderRadius: 10, background: `${item.color}18`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <item.icon size={18} color={item.color} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--text-primary)' }}>{item.label}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 500, marginTop: 2 }}>{item.sub}</div>
                </div>
                <ArrowRight size={16} color="var(--text-secondary)" />
              </div>
            ))}
          </div>
        </div>

        <div className="card" style={{ padding: 24 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <Clock size={18} color="var(--amber)" />
              <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-primary)' }}>Pending Reviews</span>
            </div>
            {pending > 0 && (
              <span onClick={() => navigate('/doctor/patients')} style={{ fontSize: 12, fontWeight: 700, color: '#3B82F6', cursor: 'pointer' }}>View all</span>
            )}
          </div>

          {loading ? (
            <div style={{ display: 'flex', justifyContent: 'center', padding: 24 }}><span className="spinner" /></div>
          ) : pendingPatients.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '24px 0' }}>
              <CheckCircle size={40} color="var(--green)" style={{ opacity: 0.3, marginBottom: 12 }} />
              <p style={{ fontSize: 14, fontWeight: 600, color: 'var(--text-muted)' }}>All caught up!</p>
              <p style={{ fontSize: 12, color: 'var(--text-secondary)', fontWeight: 500 }}>No pending reviews.</p>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {pendingPatients.map(p => {
                const isHighRisk = !!(p.latest_result || '').toLowerCase().match(/high|severe|critical/);
                return (
                  <div
                    key={p.patient_id}
                    onClick={() => navigate(`/doctor/patients/${p.patient_id}`, { state: { patient: p } })}
                    style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', borderRadius: 12, border: isHighRisk ? '1.5px solid #FECACA' : '1px solid rgba(245,158,11,0.15)', background: isHighRisk ? 'rgba(220,38,38,0.04)' : 'rgba(245,158,11,0.04)', cursor: 'pointer', transition: 'all 0.2s' }}
                    onMouseEnter={e => e.currentTarget.style.background = isHighRisk ? 'rgba(220,38,38,0.1)' : 'rgba(245,158,11,0.1)'}
                    onMouseLeave={e => e.currentTarget.style.background = isHighRisk ? 'rgba(220,38,38,0.04)' : 'rgba(245,158,11,0.04)'}
                  >
                    <div style={{ position: 'relative' }}>
                      <div style={{ width: 38, height: 38, borderRadius: '50%', background: isHighRisk ? 'rgba(220,38,38,0.15)' : 'rgba(245,158,11,0.15)', color: isHighRisk ? '#DC2626' : '#D97706', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, fontWeight: 800 }}>
                        {p.name.charAt(0).toUpperCase()}
                      </div>
                      {isHighRisk && (
                        <div style={{ position: 'absolute', top: -2, right: -2, width: 12, height: 12, borderRadius: '50%', background: '#DC2626', border: '2px solid white', animation: 'drRedPulse 1.5s ease-in-out infinite' }} />
                      )}
                    </div>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--text-primary)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.name}</div>
                      <div style={{ fontSize: 12, color: isHighRisk ? '#DC2626' : 'var(--text-muted)', fontWeight: 600 }}>
                        {isHighRisk ? '🔴 High Risk' : `ID: #${p.patient_id?.slice(-4)}`}
                      </div>
                    </div>
                    <div className="badge badge-amber">{p.pending_reviews} pending</div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Clinical Info Banner */}
      <div style={{ background: 'linear-gradient(135deg, #1E3A5F, #1E40AF)', borderRadius: 20, padding: 28, display: 'flex', alignItems: 'center', gap: 24, color: 'white', boxShadow: '0 8px 24px rgba(30,64,175,0.25)' }}>
        <div style={{ width: 60, height: 60, borderRadius: '50%', background: 'rgba(255,255,255,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Activity size={28} />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 18, fontWeight: 800, marginBottom: 6 }}>Autism Clinical Platform</div>
          <div style={{ fontSize: 13, opacity: 0.8, fontWeight: 500, lineHeight: 1.5 }}>
            Early autism screening and behavioral assessment tool. Review patient assessments and provide timely clinical feedback to support families.
          </div>
        </div>
        <button
          onClick={() => navigate('/doctor/patients')}
          style={{ padding: '12px 22px', borderRadius: 12, border: 'none', background: 'rgba(255,255,255,0.2)', color: 'white', fontSize: 14, fontWeight: 700, cursor: 'pointer', backdropFilter: 'blur(8px)', whiteSpace: 'nowrap', transition: 'background 0.2s' }}
          onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,255,255,0.3)'}
          onMouseLeave={e => e.currentTarget.style.background = 'rgba(255,255,255,0.2)'}
        >
          Open Patients →
        </button>
      </div>

      <style>{`
        @keyframes drRedPulse {
          0%, 100% { box-shadow: 0 0 0 0 rgba(220,38,38,0.45); }
          50% { box-shadow: 0 0 0 8px rgba(220,38,38,0); }
        }
        @keyframes drFadeIn {
          from { opacity: 0; transform: translateY(-8px); }
          to   { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </div>
  );
}
