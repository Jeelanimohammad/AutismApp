import { useState } from 'react';
import { User, Calendar, Phone, Mail, Lock, Hash, Shield, CheckCircle, UserPlus, X } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';

export default function AddPatient({ onClose, onSuccess }) {
  const { doctor } = useAuth();
  const [form, setForm] = useState({
    patient_id: '',
    name: '',
    dob: new Date().toISOString().split('T')[0],
    sex: 'Male',
    phone: '',
    email: '',
    password: ''
  });
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);

    try {
      // Auto-calculate age in years from DOB
      let age = 0;
      if (form.dob) {
        const today = new Date();
        const birth = new Date(form.dob);
        age = today.getFullYear() - birth.getFullYear();
        const m = today.getMonth() - birth.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--;
        if (age < 0) age = 0;
      }

      // Convert dob from yyyy-mm-dd to dd/mm/yyyy for the API
      let dobFormatted = form.dob;
      if (form.dob && form.dob.includes('-')) {
        const [y, m, d] = form.dob.split('-');
        dobFormatted = `${d}/${m}/${y}`;
      }

      const res = await api.registerPatient({ ...form, dob: dobFormatted, age, doctor_id: doctor?.doctor_id });
      if (res.success) {
        toast.success('Patient registered successfully!');
        setTimeout(() => {
          onSuccess?.();
          onClose?.();
        }, 1000);
      } else {
        toast.error(res.message || 'Registration failed.');
      }
    } catch {
      toast.error('Network error. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const isValid = form.patient_id && form.name && form.dob && form.phone && form.password;

  return (
    <div className="modal-overlay">
      <div className="modal animate-scale" style={{ maxWidth: 540 }}>
        <div className="modal-header">
          <h2 style={{ fontSize: 20, fontWeight: 800, display: 'flex', alignItems: 'center', gap: 10 }}>
            <UserPlus size={22} color="var(--green)" /> Register Patient
          </h2>
          <button onClick={onClose} style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}>
            <X size={22} />
          </button>
        </div>

        <div className="modal-body">
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
            <div className="input-group">
              <label className="input-label">Patient ID</label>
              <div className="input-field">
                <Hash size={16} className="input-icon" />
                <input type="text" placeholder="e.g. A111" value={form.patient_id} onChange={e => setForm({ ...form, patient_id: e.target.value })} />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Full Name</label>
              <div className="input-field">
                <User size={16} className="input-icon" />
                <input type="text" placeholder="Child's full name" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} />
              </div>
            </div>

              <div className="input-group">
                <label className="input-label">Date of Birth</label>
                <div className="input-field">
                  <Calendar size={16} className="input-icon" />
                  <input type="date" value={form.dob} onChange={e => setForm({ ...form, dob: e.target.value })} style={{ colorScheme: 'dark' }} />
                </div>
              </div>

            <div className="input-group">
              <label className="input-label">Sex</label>
              <div style={{ display: 'flex', gap: 12 }}>
                {['Male', 'Female', 'Other'].map(s => (
                  <button
                    key={s}
                    type="button"
                    className={`btn btn-sm ${form.sex === s ? 'btn-primary' : 'btn-ghost'}`}
                    onClick={() => setForm({ ...form, sex: s })}
                    style={{ flex: 1 }}
                  >
                    {s}
                  </button>
                ))}
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Phone</label>
              <div className="input-field">
                <Phone size={16} className="input-icon" />
                <input type="tel" placeholder="Parent's phone number" value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Email (Optional)</label>
              <div className="input-field">
                <Mail size={16} className="input-icon" />
                <input type="email" placeholder="Parent's email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} />
              </div>
            </div>

            <div className="input-group">
              <label className="input-label">Password</label>
              <div className="input-field">
                <Lock size={16} className="input-icon" />
                <input type="password" placeholder="Set login password" value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} />
              </div>
            </div>

            <button type="submit" className="btn btn-green btn-full" disabled={saving || !isValid} style={{ marginTop: 8 }}>
              {saving ? <span className="spinner"></span> : <><UserPlus size={18} /> Register Patient</>}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
