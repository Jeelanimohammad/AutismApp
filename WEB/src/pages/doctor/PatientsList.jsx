import { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Users, Activity, Trash2, Shield, UserPlus, HeartPulse } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import AddPatient from './AddPatient';
import { toast } from '../../components/Toast';

export default function PatientsList() {
  const { doctor } = useAuth();
  const navigate = useNavigate();
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [error, setError] = useState('');
  const [showAddPatient, setShowAddPatient] = useState(false);
  const pendingDeletes = useRef({});

  const fetchPatients = async () => {
    try {
      const res = await api.getPatientsList(doctor.doctor_id);
      if (res.success) setPatients(res.patients || []);
      else setError(res.message);
    } catch {
      setError('Failed to load patients.');
    } finally { setLoading(false); }
  };

  useEffect(() => { fetchPatients(); }, []);

  const handleDelete = (e, pid) => {
    e.preventDefault();
    e.stopPropagation();

    const removedItem = patients.find(p => p.patient_id === pid);
    if (!removedItem) return;
    const removedIndex = patients.indexOf(removedItem);

    // Optimistically remove from UI
    setPatients(prev => prev.filter(p => p.patient_id !== pid));

    // Schedule actual backend delete after 5-second grace period
    const timer = setTimeout(async () => {
      delete pendingDeletes.current[pid];
      try {
        const res = await api.deletePatient(pid);
        if (res.success) {
          toast.success('Patient removed permanently.');
        } else {
          // Restore on failure
          setPatients(prev => {
            const next = [...prev];
            next.splice(removedIndex, 0, removedItem);
            return next;
          });
          toast.error(res.message || 'Delete failed — patient restored.');
        }
      } catch {
        setPatients(prev => {
          const next = [...prev];
          next.splice(removedIndex, 0, removedItem);
          return next;
        });
        toast.error('Delete failed — patient restored.');
      }
    }, 5000);

    pendingDeletes.current[pid] = timer;

    toast.undoable('Patient removed.', () => {
      clearTimeout(pendingDeletes.current[pid]);
      delete pendingDeletes.current[pid];
      setPatients(prev => {
        const next = [...prev];
        next.splice(removedIndex, 0, removedItem);
        return next;
      });
      toast.success('Patient restored.');
    });
  };

  const filtered = patients.filter(p => p.name.toLowerCase().includes(search.toLowerCase()));

  // Stats
  const total = patients.length;
  const pending = patients.filter(p => p.pending_reviews > 0).length;
  const advised = total - pending;

  return (
    <div className="animate-fade">
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 32 }}>
        <div>
          <h1 style={{ fontSize: 28, fontWeight: 900, marginBottom: 8 }}>{new Date().getHours() < 12 ? 'Good morning' : new Date().getHours() < 17 ? 'Good afternoon' : 'Good evening'}, Dr. {doctor.name.split(' ')[0]}</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Here is your clinical overview for today.</p>
        </div>
        <button className="btn btn-green" onClick={() => setShowAddPatient(true)} style={{ gap: 8 }}>
          <UserPlus size={18} /> Register Patient
        </button>
      </div>

      {/* Stats */}
      <div style={{ display: 'flex', gap: 16, marginBottom: 32, overflowX: 'auto', paddingBottom: 8 }}>
        <div className="stat-card" style={{ background: 'linear-gradient(135deg, var(--blue), var(--purple))' }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <div style={{ width: 40, height: 40, borderRadius: '50%', background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Users size={20} />
            </div>
          </div>
          <div>
            <div className="stat-card-value">{total}</div>
            <div className="stat-card-label">Total Patients</div>
          </div>
        </div>

        <div className="stat-card" style={{ background: 'linear-gradient(135deg, var(--cyan), var(--green))' }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <div style={{ width: 40, height: 40, borderRadius: '50%', background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Activity size={20} />
            </div>
          </div>
          <div>
            <div className="stat-card-value">{advised}</div>
            <div className="stat-card-label">Advised</div>
          </div>
        </div>

        <div className="stat-card" style={{ background: 'linear-gradient(135deg, var(--orange), var(--amber))' }}>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <div style={{ width: 40, height: 40, borderRadius: '50%', background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <HeartPulse size={20} />
            </div>
          </div>
          <div>
            <div className="stat-card-value">{pending}</div>
            <div className="stat-card-label">Pending Review</div>
          </div>
        </div>
      </div>

      {error && <div className="alert alert-error" style={{ marginBottom: 24 }}><Shield size={16} />{error}</div>}

      {/* Search & List */}
      <div className="card" style={{ padding: 24 }}>
        <div className="search-bar" style={{ marginBottom: 24, maxWidth: 400 }}>
          <Search size={18} className="input-icon" />
          <input type="text" placeholder="Search patients..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>

        {loading ? <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}><span className="spinner spinner-lg"></span></div> : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {filtered.length === 0 ? (
              <p style={{ textAlign: 'center', color: 'var(--text-muted)', padding: 40 }}>No patients found.</p>
            ) : (
              filtered.map(p => (
                <div key={p.patient_id} className="patient-row" onClick={() => navigate(`/doctor/patients/${p.patient_id}`, { state: { patient: p } })}>
                  <div className="patient-avatar">{p.name.charAt(0).toUpperCase()}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 16, fontWeight: 700, color: 'var(--text-primary)' }}>{p.name}</div>
                    <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>ID: #{p.patient_id.slice(-4)}</div>
                  </div>
                  {p.age && <div className="badge badge-blue">{p.age} yrs</div>}
                  {p.pending_reviews > 0 && <div className="badge badge-amber">{p.pending_reviews} Pending</div>}
                  <button className="btn-icon" onClick={(e) => handleDelete(e, p.patient_id)} style={{ color: 'var(--rose)', background: 'transparent', border: 'none', cursor: 'pointer' }}>
                    <Trash2 size={18} />
                  </button>
                </div>
              ))
            )}
          </div>
        )}
      </div>

      {showAddPatient && <AddPatient onClose={() => setShowAddPatient(false)} onSuccess={fetchPatients} />}
    </div>
  );
}
