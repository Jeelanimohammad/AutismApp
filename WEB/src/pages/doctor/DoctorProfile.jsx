import { useState, useEffect } from 'react';
import { User, Mail, Building, Save, Shield, CheckCircle, Camera, Trash2, Phone, Lock } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';

export default function DoctorProfile() {
  const { doctor, loginDoctor } = useAuth();
  const [form, setForm] = useState({ name: '', email: '', phone: '', specialization: '', profile_image: '' });
  const [previewImage, setPreviewImage] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState({ type: '', text: '' });


  useEffect(() => {
    async function load() {
      try {
        const res = await api.getDoctorProfile(doctor.doctor_id);
        if (res.success && res.doctor) {
          setForm({
            name: res.doctor.name || '',
            email: res.doctor.email || '',
            phone: res.doctor.phone || '',
            specialization: res.doctor.specialization || '',
            profile_image: res.doctor.profile_image || ''
          });
          if (res.doctor.profile_image) {
            setPreviewImage(api.resolveImageUrl(res.doctor.profile_image));
          }
        }
      } finally { setLoading(false); }
    }
    load();
  }, [doctor.doctor_id]);

  const handleImagePick = (e) => {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewImage(reader.result);
        setForm({ ...form, profile_image: reader.result });
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRemoveImage = () => {
    setPreviewImage(null);
    setForm({ ...form, profile_image: '' });
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true); setMsg({ type: '', text: '' });
    
    // Simple frontend validation for phone number
    if (!/^[0-9]{10}$/.test(form.phone.trim())) {
      setMsg({ type: 'error', text: 'Phone number must be exactly 10 digits.' });
      setSaving(false);
      return;
    }

    try {
      const res = await api.updateDoctorProfile({ doctor_id: doctor.doctor_id, ...form });
      if (res.success) {
        setMsg({ type: 'success', text: 'Profile updated successfully.' });
        toast.success('Profile updated successfully.');
        loginDoctor({ ...doctor, ...form, profile_image: previewImage });
      } else {
        setMsg({ type: 'error', text: res.message || 'Update failed.' });
        toast.error(res.message || 'Update failed.');
      }
    } catch {
      setMsg({ type: 'error', text: 'Network error.' });
      toast.error('Network error. Please try again.');
    } finally { setSaving(false); }
  };



  if (loading) return <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}><span className="spinner spinner-lg"></span></div>;

  return (
    <div className="animate-fade">
      <div style={{ marginBottom: 32 }}>
        <h1 style={{ fontSize: 28, fontWeight: 900, marginBottom: 8 }}>Professional Profile</h1>
        <p style={{ color: 'var(--text-secondary)' }}>Manage your clinical identity and credentials.</p>
      </div>

      <div className="card" style={{ maxWidth: 600, padding: 32 }}>
        {msg.text && (
          <div className={`alert alert-${msg.type}`} style={{ marginBottom: 24 }}>
            {msg.type === 'success' ? <CheckCircle size={16} /> : <Shield size={16} />}
            <span>{msg.text}</span>
          </div>
        )}

        {/* Profile Image */}
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: 32 }}>
          <div style={{ position: 'relative' }}>
            {previewImage ? (
              <img src={previewImage} alt="Profile" className="avatar-circle" />
            ) : (
              <div className="avatar-placeholder">{form.name.charAt(0).toUpperCase()}</div>
            )}
            <label style={{ position: 'absolute', bottom: 0, right: 0, background: 'var(--green)', color: 'white', padding: 8, borderRadius: '50%', cursor: 'pointer', boxShadow: 'var(--shadow-sm)' }}>
              <Camera size={16} />
              <input type="file" accept="image/*" style={{ display: 'none' }} onChange={handleImagePick} />
            </label>
          </div>
          {previewImage && (
            <button type="button" className="btn btn-ghost btn-sm" onClick={handleRemoveImage} style={{ marginTop: 12, color: 'var(--rose)' }}>
              <Trash2 size={14} /> Remove Photo
            </button>
          )}
        </div>

        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          <div className="input-group">
            <label className="input-label">Full Name</label>
            <div className="input-field">
              <User size={18} className="input-icon" />
              <input type="text" value={form.name} onChange={e => setForm({...form, name: e.target.value})} required />
            </div>
          </div>

          <div className="input-group">
            <label className="input-label">Professional Email</label>
            <div className="input-field">
              <Mail size={18} className="input-icon" />
              <input type="email" value={form.email} onChange={e => setForm({...form, email: e.target.value})} required />
            </div>
          </div>

          <div className="input-group">
            <label className="input-label">Phone Number</label>
            <div className="input-field">
              <Phone size={18} className="input-icon" />
              <input type="tel" value={form.phone} onChange={e => setForm({...form, phone: e.target.value})} required />
            </div>
          </div>

          <div className="input-group">
            <label className="input-label">Specialization</label>
            <div className="input-field">
              <Building size={18} className="input-icon" />
              <input type="text" value={form.specialization} onChange={e => setForm({...form, specialization: e.target.value})} required />
            </div>
          </div>

          <button type="submit" className="btn btn-primary" disabled={saving || !form.name.trim()}>
            {saving ? <span className="spinner"></span> : <><Save size={18} /> Save Changes</>}
          </button>
        </form>
      </div>


    </div>
  );
}
