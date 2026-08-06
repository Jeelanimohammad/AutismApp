import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../api/api';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell,
  PieChart, Pie, Legend, CartesianGrid
} from 'recharts';
import {
  TrendingUp, Users, CheckCircle, Clock, BarChart2, Activity,
  AlertCircle, ArrowUpRight
} from 'lucide-react';

export default function DoctorAnalytics() {
  const { doctor } = useAuth();
  const navigate = useNavigate();
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!doctor?.doctor_id) return;
    api.getPatientsList(doctor.doctor_id)
      .then(res => {
        if (res.success) setPatients(res.patients || []);
      })
      .finally(() => setLoading(false));
  }, [doctor?.doctor_id]);

  const total = patients.length;
  const totalPending = patients.reduce((acc, p) => acc + (parseInt(p.pending_reviews) || 0), 0);
  const totalReviewed = patients.reduce((acc, p) => acc + (parseInt(p.reviewed_count) || 0), 0);
  const reviewedFullyPatients = patients.filter(p => parseInt(p.has_advice) === 1 && (parseInt(p.pending_reviews) || 0) === 0).length;
  const reviewRate = total > 0 ? Math.round((reviewedFullyPatients / total) * 100) : 0;

  // Gender distribution
  const genderData = (() => {
    const m = patients.filter(p => p.sex?.toLowerCase() === 'male').length;
    const f = patients.filter(p => p.sex?.toLowerCase() === 'female').length;
    const o = patients.filter(p => !['male','female'].includes(p.sex?.toLowerCase())).length;
    const arr = [
      { name: 'Male', value: m, color: '#3B82F6' },
      { name: 'Female', value: f, color: '#EC4899' },
      { name: 'Other', value: o, color: '#8B5CF6' },
    ].filter(d => d.value > 0);
    return arr;
  })();

  // Age distribution brackets
  const ageBrackets = (() => {
    const brackets = [
      { name: 'Under 2', min: 0, max: 2, count: 0 },
      { name: '2–4 yrs', min: 2, max: 4, count: 0 },
      { name: '4–6 yrs', min: 4, max: 6, count: 0 },
      { name: '6–10 yrs', min: 6, max: 10, count: 0 },
      { name: '10+ yrs', min: 10, max: 999, count: 0 },
    ];
    patients.forEach(p => {
      const age = parseFloat(p.age) || 0;
      const b = brackets.find(b => age >= b.min && age < b.max);
      if (b) b.count++;
    });
    return brackets.map(b => ({ name: b.name, Patients: b.count }));
  })();

  // Risk distribution (proportional split between pending reviews and reviewed reports)
  const riskData = [
    { name: 'High Risk', value: totalPending, color: '#EF4444' },
    { name: 'Reviewed', value: totalReviewed, color: '#10B981' },
  ].filter(d => d.value > 0);

  const StatMini = ({ label, value, icon: Icon, color, sub }) => (
    <div className="card" style={{
      padding: '20px 24px',
      display: 'flex', flexDirection: 'column', gap: 8
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div style={{
          width: 40, height: 40, borderRadius: 12,
          background: `${color}25`,
          display: 'flex', alignItems: 'center', justifyContent: 'center'
        }}>
          <Icon size={18} color={color} />
        </div>
        {sub != null && (
          <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--green-light)', display: 'flex', alignItems: 'center', gap: 3 }}>
            <ArrowUpRight size={12} />{sub}%
          </span>
        )}
      </div>
      <div style={{ fontSize: 32, fontWeight: 900, color: 'var(--text-primary)', lineHeight: 1 }}>{value}</div>
      <div style={{ fontSize: 13, color: 'var(--text-muted)', fontWeight: 600 }}>{label}</div>
    </div>
  );

  if (loading) return (
    <div style={{ display: 'flex', justifyContent: 'center', padding: 80 }}>
      <span className="spinner spinner-lg" />
    </div>
  );

  return (
    <div className="animate-fade" style={{ maxWidth: 960 }}>
      {/* Header */}
      <div style={{ marginBottom: 32 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
          <BarChart2 size={18} color="var(--cyan)" />
          <span style={{ fontSize: 13, fontWeight: 700, letterSpacing: 1.5, color: 'var(--cyan)', textTransform: 'uppercase' }}>
            Clinical Analytics
          </span>
        </div>
        <h1 style={{ fontSize: 30, fontWeight: 900, color: 'var(--text-primary)', marginBottom: 4 }}>
          Practice Overview
        </h1>
        <p style={{ fontSize: 15, color: 'var(--text-muted)', fontWeight: 500 }}>
          Data-driven insights across your patient panel.
        </p>
      </div>

      {/* KPI Strip */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 28 }}>
        <StatMini label="Total Patients" value={total} icon={Users} color="#3B82F6" />
        <StatMini label="Pending Reviews" value={totalPending} icon={Clock} color="#F59E0B" />
        <StatMini label="Fully Reviewed" value={reviewedFullyPatients} icon={CheckCircle} color="#10B981" />
        <StatMini label="Review Rate" value={`${reviewRate}%`} icon={TrendingUp} color="#8B5CF6" />
      </div>

      {/* Charts Row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 20, marginBottom: 20 }}>

        {/* Age Distribution Bar */}
        <div className="card" style={{ padding: 28 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 24 }}>
            <Activity size={18} color="var(--blue-light)" />
            <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-primary)' }}>Patient Age Distribution</span>
          </div>
          {total === 0 ? (
            <div style={{ height: 200, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)' }}>
              <p style={{ fontWeight: 600 }}>No data yet</p>
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={ageBrackets} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: 'var(--text-muted)', fontWeight: 600 }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: 'var(--text-muted)' }} allowDecimals={false} />
                <Tooltip
                  cursor={{ fill: 'rgba(255,255,255,0.05)' }}
                  contentStyle={{ borderRadius: 12, border: '1px solid rgba(255,255,255,0.1)', background: 'rgba(15,23,42,0.9)', color: '#fff', boxShadow: '0 8px 24px rgba(0,0,0,0.4)', fontWeight: 700 }}
                  formatter={(v) => [v, 'Patients']}
                />
                <Bar dataKey="Patients" radius={[8,8,8,8]} barSize={36} fill="var(--blue)">
                  {ageBrackets.map((_, i) => (
                    <Cell key={i} fill={i % 2 === 0 ? 'var(--blue)' : 'var(--cyan)'} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

        {/* Review Status Pie */}
        <div className="card" style={{ padding: 28 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 24 }}>
            <AlertCircle size={18} color="var(--amber)" />
            <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-primary)' }}>Review Status</span>
          </div>
          {total === 0 ? (
            <div style={{ height: 200, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)' }}>
              <p style={{ fontWeight: 600 }}>No data yet</p>
            </div>
          ) : (
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie
                  data={riskData}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={80}
                  paddingAngle={4}
                  dataKey="value"
                  stroke="none"
                >
                  {riskData.map((entry, i) => (
                    <Cell key={i} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ borderRadius: 12, border: '1px solid rgba(255,255,255,0.1)', background: 'rgba(15,23,42,0.9)', color: '#fff', boxShadow: '0 8px 24px rgba(0,0,0,0.4)', fontWeight: 700 }}
                />
                <Legend
                  formatter={(value) => <span style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-muted)' }}>{value}</span>}
                />
              </PieChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      {/* Gender Distribution */}
      {genderData.length > 0 && (
        <div className="card" style={{ padding: 28, marginBottom: 20 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 20 }}>
            <Users size={18} color="var(--purple-light)" />
            <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-primary)' }}>Gender Distribution</span>
          </div>
          <div style={{ display: 'flex', gap: 16 }}>
            {genderData.map(g => (
              <div key={g.name} style={{ flex: 1, background: `${g.color}15`, borderRadius: 16, padding: '20px 24px', border: `1px solid ${g.color}30` }}>
                <div style={{ fontSize: 32, fontWeight: 900, color: g.color }}>{g.value}</div>
                <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-muted)', marginTop: 4 }}>{g.name}</div>
                <div style={{ height: 4, background: 'rgba(255,255,255,0.1)', borderRadius: 2, marginTop: 12 }}>
                  <div style={{ height: '100%', width: `${total > 0 ? (g.value/total)*100 : 0}%`, background: g.color, borderRadius: 2, transition: 'width 1s ease' }} />
                </div>
                <div style={{ fontSize: 11, fontWeight: 700, color: g.color, marginTop: 6 }}>
                  {total > 0 ? Math.round((g.value/total)*100) : 0}% of total
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Pending Patients Table */}
      {totalPending > 0 && (
        <div className="card" style={{ padding: 28 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <Clock size={18} color="var(--amber)" />
              <span style={{ fontSize: 15, fontWeight: 800, color: 'var(--text-primary)' }}>Patients Needing Attention</span>
            </div>
            <span
              onClick={() => navigate('/doctor/patients')}
              style={{ fontSize: 12, fontWeight: 700, color: 'var(--cyan-light)', cursor: 'pointer' }}
            >
              View all →
            </span>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {patients.filter(p => p.pending_reviews > 0).map(p => (
              <div
                key={p.patient_id}
                onClick={() => navigate(`/doctor/patients/${p.patient_id}`, { state: { patient: p } })}
                style={{
                  display: 'flex', alignItems: 'center', gap: 14, padding: '14px 16px',
                  borderRadius: 14, border: '1px solid rgba(245,158,11,0.2)',
                  background: 'rgba(245,158,11,0.05)', cursor: 'pointer', transition: 'all 0.2s'
                }}
                onMouseEnter={e => e.currentTarget.style.background = 'rgba(245,158,11,0.1)'}
                onMouseLeave={e => e.currentTarget.style.background = 'rgba(245,158,11,0.05)'}
              >
                <div style={{
                  width: 40, height: 40, borderRadius: '50%',
                  background: 'rgba(245,158,11,0.2)', color: 'var(--amber)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 16, fontWeight: 800, flexShrink: 0
                }}>
                  {p.name.charAt(0).toUpperCase()}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 700, color: 'var(--text-primary)' }}>{p.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 500 }}>ID: #{p.patient_id?.slice(-4)} · {p.age} yrs · {p.sex}</div>
                </div>
                <div className="badge badge-amber">{p.pending_reviews} pending</div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
