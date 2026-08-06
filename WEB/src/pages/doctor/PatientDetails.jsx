import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import { ArrowLeft, CheckCircle, XCircle, FileText, Send, Loader, Trash2, Clock, Download } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';

export default function PatientDetails() {
  const { patientId } = useParams();
  const navigate = useNavigate();
  const { state } = useLocation();
  const { doctor } = useAuth();
  const patientName = state?.patient?.name || 'Patient';

  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedAsmt, setSelectedAsmt] = useState(null);

  // Advice states
  const [adviceText, setAdviceText] = useState('');
  const [adviceList, setAdviceList] = useState([]);
  const [loadingAdvice, setLoadingAdvice] = useState(false);

  useEffect(() => {
    loadHistory();
  }, [patientId]);
  useEffect(() => {
    if (selectedAsmt) loadAdvice();
  }, [selectedAsmt]);

  const loadHistory = async () => {
    setLoading(true);
    try {
      const res = await api.getAssessments(patientId);
      const list = Array.isArray(res) ? res : (res.assessments || []);
      setHistory(list);
    } finally { setLoading(false); }
  };

  const loadAssessment = async (id) => {
    try {
      const res = await api.getAssessmentDetails(id);
      if (res.success) setSelectedAsmt({ ...res, id });
    } catch (e) { toast.error('Failed to load details'); }
  };

  const pendingDeletes = useRef({});

  const deleteAssessment = (id) => {
    // Save the item so we can restore on undo
    const removedItem = history.find(a => a.id === id);
    if (!removedItem) return;
    const removedIndex = history.indexOf(removedItem);

    // Immediately hide from UI
    if (selectedAsmt?.id === id) setSelectedAsmt(null);
    setHistory(prev => prev.filter(a => a.id !== id));

    // Schedule actual backend delete after grace period
    const timer = setTimeout(async () => {
      delete pendingDeletes.current[id];
      try {
        const res = await api.deleteAssessment(id);
        if (res.success) {
          toast.success('Assessment deleted permanently.');
        } else {
          // Backend failed — restore
          setHistory(prev => {
            const next = [...prev];
            next.splice(removedIndex, 0, removedItem);
            return next;
          });
          toast.error(res.message || 'Delete failed — report restored.');
        }
      } catch {
        setHistory(prev => {
          const next = [...prev];
          next.splice(removedIndex, 0, removedItem);
          return next;
        });
        toast.error('Delete failed — report restored.');
      }
    }, 5000);

    pendingDeletes.current[id] = timer;

    // Show undo toast
    toast.undoable('Assessment deleted.', () => {
      clearTimeout(pendingDeletes.current[id]);
      delete pendingDeletes.current[id];
      setHistory(prev => {
        const next = [...prev];
        next.splice(removedIndex, 0, removedItem);
        return next;
      });
      toast.success('Assessment restored.');
    });
  };

  const loadAdvice = async () => {
    try {
      const res = await api.getAdvice(patientId, selectedAsmt.id);
      setAdviceList(Array.isArray(res) ? res : (res.advice || []));
    } catch (e) {}
  };

  const handleDownloadReport = () => {
    if (!selectedAsmt) return;

    const reportWin = window.open('', '_blank');

    const reportContent = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Clinical Analysis Report - ${patientName}</title>
  <style>
    * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; color-adjust: exact !important; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f172a !important; color: #f8fafc !important; padding: 30px; margin: 0; }
    .card { max-width: 700px; margin: 0 auto; background: #1e293b !important; border-radius: 16px; border: 1px solid #334155 !important; padding: 32px; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.3); }
    .header { border-bottom: 1px solid #334155; padding-bottom: 20px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; }
    .logo { color: #06b6d4 !important; font-size: 24px; font-weight: 900; letter-spacing: -0.5px; }
    .sub { color: #94a3b8 !important; font-size: 13px; margin-top: 4px; }
    .print-btn { background: #06b6d4; color: #0f172a; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 800; cursor: pointer; font-size: 13px; transition: all 0.2s; }
    .print-btn:hover { background: #22d3ee; }
    @media print {
      .print-btn { display: none !important; }
      body { background: #0f172a !important; color: #f8fafc !important; padding: 20px; }
      .card { background: #1e293b !important; border: 1px solid #334155 !important; color: #f8fafc !important; }
    }
    .section-title { font-size: 14px; font-weight: 800; text-transform: uppercase; color: #06b6d4 !important; letter-spacing: 1px; margin: 24px 0 12px 0; }
    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; font-size: 14px; background: rgba(15,23,42,0.8) !important; padding: 16px; border-radius: 8px; border: 1px solid #334155; }
    .info-label { color: #94a3b8 !important; }
    .info-val { color: #f8fafc !important; font-weight: 700; }
    .badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 800; background: rgba(6,182,212,0.2) !important; color: #06b6d4 !important; border: 1px solid rgba(6,182,212,0.4); }
    table { width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 14px; }
    th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #334155 !important; }
    th { color: #94a3b8 !important; font-size: 11px; text-transform: uppercase; }
    td { color: #f8fafc !important; }
    .advice-box { background: rgba(15,23,42,0.8) !important; border-left: 3px solid #06b6d4 !important; padding: 12px 16px; border-radius: 0 8px 8px 0; margin-bottom: 10px; font-size: 14px; color: #f8fafc !important; }
  </style>
</head>
<body>
  <div class="card">
    <div class="header">
      <div>
        <div class="logo">AUTISCREEN</div>
        <div class="sub">Clinical Evaluation & Assessment Report</div>
      </div>
      <button class="print-btn" onclick="window.print()">Print / Save as PDF</button>
    </div>

    <div class="info-grid">
      <div><span class="info-label">Patient Name:</span> <span class="info-val">${patientName}</span></div>
      <div><span class="info-label">Patient ID:</span> <span class="info-val">#${patientId}</span></div>
      <div><span class="info-label">Date Evaluated:</span> <span class="info-val">${selectedAsmt.created_at}</span></div>
      <div><span class="info-label">Result:</span> <span class="badge">${selectedAsmt.result_message}</span></div>
    </div>

    <div class="section-title">Symptom Assessment Responses</div>
    <table>
      <thead>
        <tr><th>Symptom Indicator</th><th>Response</th></tr>
      </thead>
      <tbody>
        ${(selectedAsmt.responses || []).map(r => `<tr><td>${r.symptom_display_name || r.symptom_name}</td><td><strong>${r.response}</strong></td></tr>`).join('')}
      </tbody>
    </table>

    <div class="section-title">Doctor Notes & Clinical Feedback</div>
    ${adviceList.length > 0 ? adviceList.map(a => `<div class="advice-box"><strong>Dr. ${a.doctor_name}</strong> <span style="color:#64748b; font-size:12px">(${a.created_at})</span><br><div style="margin-top:4px">${a.advice_text}</div></div>`).join('') : '<p style="color:#64748b; font-size:14px">No clinical notes recorded.</p>'}
  </div>
</body>
</html>`;

    if (reportWin) {
      reportWin.document.open();
      reportWin.document.write(reportContent);
      reportWin.document.close();
    }

    toast.success('Report opened in new window!');
  };

  const submitAdvice = async () => {
    if (!adviceText.trim()) return;
    setLoadingAdvice(true);
    try {
      const res = await api.addAdvice({
        patient_id: patientId,
        doctor_id: doctor.doctor_id,
        doctor_name: doctor.name,
        assessment_id: selectedAsmt.id,
        advice_text: adviceText
      });
      if (!res.success) throw new Error(res.message || 'Server returned failure');
      setAdviceText('');
      toast.success('Clinical advice posted successfully.');
      loadAdvice();
      loadHistory();
    } catch (err) {
      console.error("Submit advice error:", err);
      toast.error('Failed to post advice. Please try again.');
    } finally { setLoadingAdvice(false); }
  };

  if (loading) return <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}><span className="spinner spinner-lg"></span></div>;

  return (
    <div className="animate-fade">
      <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 32 }}>
        <button className="btn btn-ghost btn-icon" onClick={() => selectedAsmt ? setSelectedAsmt(null) : navigate(-1)}>
          <ArrowLeft size={18} />
        </button>
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 900 }}>{selectedAsmt ? 'Clinical Analysis' : patientName}</h1>
          <p style={{ color: 'var(--text-secondary)' }}>ID: #{patientId.slice(-4)}</p>
        </div>
      </div>

      {!selectedAsmt ? (
        // History List
        <div className="card" style={{ padding: 24 }}>
          <h2 style={{ fontSize: 13, fontWeight: 800, color: 'var(--cyan-light)', textTransform: 'uppercase', letterSpacing: 1, marginBottom: 20 }}>Clinical Chronology</h2>
          {history.length === 0 ? (
            <p style={{ color: 'var(--text-muted)' }}>No history recorded yet.</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
              {history.map(a => (
                <div key={a.id} className="assessment-card" onClick={() => loadAssessment(a.id)}>
                  <div style={{ width: 48, height: 48, borderRadius: 12, background: 'rgba(6,182,212,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--cyan)' }}>
                    {a.has_feedback === 1 ? <CheckCircle size={24} /> : <FileText size={24} />}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 16, fontWeight: 800 }}>{a.result_message}</div>
                    <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 4, fontFamily: 'monospace' }}>{a.created_at}</div>
                  </div>
                  <button className="btn-icon" onClick={(e) => { e.stopPropagation(); deleteAssessment(a.id); }} style={{ color: 'var(--rose)', background: 'transparent', border: 'none', cursor: 'pointer' }}>
                    <Trash2 size={18} />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      ) : (
        // Assessment Details
        <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
          {/* Header Card */}
          <div className="card" style={{ padding: 32 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
              <div className="badge badge-cyan" style={{ padding: '6px 12px', fontSize: 11 }}>
                Analysis Result
              </div>
              <button className="btn btn-ghost btn-sm" onClick={() => handleDownloadReport()} style={{ gap: 6 }}>
                <Download size={14} /> Download Report
              </button>
            </div>
            <h2 style={{ fontSize: 24, fontWeight: 900, marginBottom: 12, color: 'var(--text-primary)' }}>{selectedAsmt.result_message}</h2>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--text-muted)', fontSize: 13, fontWeight: 600 }}>
              <Clock size={14} /> Timeline: {selectedAsmt.created_at}
            </div>
          </div>

          {/* Matrix */}
          <div className="card" style={{ padding: 32 }}>
            <div className="badge badge-gray" style={{ padding: '6px 12px', fontSize: 11, marginBottom: 24 }}>
              Symptom Matrix
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
              {selectedAsmt.responses.map((r, i) => (
                <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', paddingBottom: 16, borderBottom: i < selectedAsmt.responses.length - 1 ? '1px solid var(--border)' : 'none' }}>
                  <div style={{ fontSize: 15, fontWeight: 600, color: 'var(--text-primary)', paddingRight: 20 }}>{r.symptom_display_name || r.symptom_name}</div>
                  <div className={`badge ${r.response.toLowerCase() === 'yes' ? 'badge-green' : 'badge-red'}`} style={{ flexShrink: 0, padding: '6px 10px' }}>
                    {r.response.toLowerCase() === 'yes' ? <CheckCircle size={12} /> : <XCircle size={12} />}
                    {r.response}
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Advice */}
          <div className="card" style={{ padding: 32 }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <FileText size={20} color="var(--purple-light)" />
                <h3 style={{ fontSize: 14, fontWeight: 800, color: 'var(--purple-light)', textTransform: 'uppercase' }}>Clinical Guidance</h3>
              </div>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 16, marginBottom: 24 }}>
              <textarea
                className="input-field"
                style={{ minHeight: 100, resize: 'vertical', width: '100%', padding: 16, fontSize: 14, color: 'var(--text-primary)', background: 'var(--bg-input)' }}
                placeholder="Write clinical advice here..."
                value={adviceText}
                onChange={e => setAdviceText(e.target.value)}
              />
              <button className="btn btn-primary" style={{ alignSelf: 'flex-end' }} disabled={!adviceText.trim() || loadingAdvice} onClick={submitAdvice}>
                {loadingAdvice ? <span className="spinner"></span> : <><Send size={16} /> Post Advice</>}
              </button>
            </div>

            {adviceList.length === 0 ? (
              <p style={{ color: 'var(--text-muted)', textAlign: 'center', fontSize: 14 }}>No clinical notes yet.</p>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                {adviceList.map(a => (
                  <div key={a.id} className="advice-bubble">
                    <p style={{ fontSize: 15, fontWeight: 700, color: 'var(--text-primary)', marginBottom: 12 }}>{a.advice_text}</p>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 11, fontWeight: 700, fontFamily: 'monospace' }}>
                      <span style={{ color: 'var(--cyan)' }}>DR. {a.doctor_name?.toUpperCase()}</span>
                      <span style={{ color: 'var(--text-muted)' }}>{a.created_at}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
