import React, { useState, useEffect } from 'react';
import { Play, Clock, CheckCircle, FileText, ChevronDown, ChevronUp, Download, Trash2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';
import { toast } from '../../components/Toast';
import { BarChart, Bar, XAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';

export default function AssessmentList() {
  const { patient } = useAuth();
  const navigate = useNavigate();
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [expandedId, setExpandedId] = useState(null);
  const [details, setDetails] = useState({});
  const [advice, setAdvice] = useState({});

  useEffect(() => {
    async function load() {
      try {
        const res = await api.getAssessments(patient.patient_id);
        const list = Array.isArray(res) ? res : (res.assessments || []);
        setHistory(list);
      } finally { setLoading(false); }
    }
    load();
  }, [patient.patient_id]);

  const loadDetails = async (id) => {
    if (expandedId === id) { setExpandedId(null); return; }
    setExpandedId(id);
    if (!details[id]) {
      const [resDet, resAdv] = await Promise.all([
        api.getAssessmentDetails(id),
        api.getAdvice(patient.patient_id, id)
      ]);
      if (resDet.success) setDetails(prev => ({ ...prev, [id]: resDet }));
      const adviceArr = Array.isArray(resAdv) ? resAdv : (resAdv.advice || []);
      setAdvice(prev => ({ ...prev, [id]: adviceArr }));
    }
  };

  const pendingDeletes = React.useRef({});

  const deleteAssessment = (id, e) => {
    e.stopPropagation();

    // Save the item so we can restore it on undo
    const removedItem = history.find(a => a.id === id);
    if (!removedItem) return;
    const removedIndex = history.indexOf(removedItem);

    // Immediately hide from UI
    if (expandedId === id) setExpandedId(null);
    setHistory(prev => prev.filter(a => a.id !== id));

    // Schedule the actual backend delete after grace period
    const timer = setTimeout(async () => {
      delete pendingDeletes.current[id];
      try {
        const res = await api.deleteAssessment(id);
        if (res.success) {
          toast.success('Report deleted permanently.');
        } else {
          // Backend failed — restore the item
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
    toast.undoable('Report deleted.', () => {
      clearTimeout(pendingDeletes.current[id]);
      delete pendingDeletes.current[id];
      // Restore the item back into the list
      setHistory(prev => {
        const next = [...prev];
        next.splice(removedIndex, 0, removedItem);
        return next;
      });
      toast.success('Report restored.');
    });
  };

  const handleDownloadReport = async (asmtId, resultMessage, createdAt) => {
    // Open a new tab immediately while user click gesture is active
    const reportWin = window.open('', '_blank');
    if (reportWin) {
      reportWin.document.write('<!DOCTYPE html><html><head><title>Loading Report...</title><style>body{background:#0f172a;color:#06b6d4;font-family:system-ui;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}</style></head><body><h2>Generating Clinical Evaluation Report...</h2></body></html>');
    }

    let asmtDetails = details[asmtId];
    let asmtAdvice = advice[asmtId] || [];

    if (!asmtDetails) {
      try {
        const [resDet, resAdv] = await Promise.all([
          api.getAssessmentDetails(asmtId),
          api.getAdvice(patient.patient_id, asmtId)
        ]);
        if (resDet.success) {
          asmtDetails = resDet;
          setDetails(prev => ({ ...prev, [asmtId]: resDet }));
        }
        asmtAdvice = Array.isArray(resAdv) ? resAdv : (resAdv.advice || []);
        setAdvice(prev => ({ ...prev, [asmtId]: asmtAdvice }));
      } catch (err) {
        if (reportWin) reportWin.close();
        toast.error('Failed to load report data.');
        return;
      }
    }

    if (!asmtDetails) {
      if (reportWin) reportWin.close();
      toast.error('Report data is not available.');
      return;
    }

    const reportContent = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Autism Screening Report - ${patient.name}</title>
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
        <div class="sub">Official Clinical Autism Evaluation Report</div>
      </div>
      <button class="print-btn" onclick="window.print()">Print / Save as PDF</button>
    </div>

    <div class="info-grid">
      <div><span class="info-label">Patient Name:</span> <span class="info-val">${patient.name}</span></div>
      <div><span class="info-label">Patient ID:</span> <span class="info-val">#${patient.patient_id}</span></div>
      <div><span class="info-label">Date Evaluated:</span> <span class="info-val">${createdAt}</span></div>
      <div><span class="info-label">Result:</span> <span class="badge">${resultMessage}</span></div>
    </div>

    <div class="section-title">Symptom Assessment Responses</div>
    <table>
      <thead>
        <tr><th>Symptom Indicator</th><th>Response</th></tr>
      </thead>
      <tbody>
        ${(asmtDetails.responses || []).map(r => `<tr><td>${r.symptom_display_name || r.symptom_name}</td><td><strong>${r.response}</strong></td></tr>`).join('')}
      </tbody>
    </table>

    <div class="section-title">Doctor Notes & Clinical Feedback</div>
    ${asmtAdvice.length > 0 ? asmtAdvice.map(a => `<div class="advice-box"><strong>Dr. ${a.doctor_name}</strong> <span style="color:#64748b; font-size:12px">(${a.created_at})</span><br><div style="margin-top:4px">${a.advice_text}</div></div>`).join('') : '<p style="color:#64748b; font-size:14px">No clinical guidance recorded yet.</p>'}
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

  const processChartData = () => {
    const data = [];
    const now = new Date();
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const monthLabel = d.toLocaleString('default', { month: 'short' });

      const monthAssessments = history.filter(a => {
        const aDate = new Date(a.created_at);
        return aDate.getMonth() === d.getMonth() && aDate.getFullYear() === d.getFullYear();
      });

      let maxSev = 0;
      monthAssessments.forEach(a => {
        const msg = a.result_message.toLowerCase();
        let sev = 1;
        if (msg.includes('high') || msg.includes('severe')) sev = 3;
        else if (msg.includes('moderate')) sev = 2;
        if (sev > maxSev) maxSev = sev;
      });

      data.push({
        name: monthLabel,
        count: monthAssessments.length,
        severity: maxSev || 1
      });
    }
    return data;
  };

  const chartData = processChartData();

  return (
    <div className="animate-fade">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 32 }}>
        <div>
          <h1 style={{ fontSize: 28, fontWeight: 900, marginBottom: 8 }}>{patient.name}'s History</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Review past assessments and clinical advice.</p>
        </div>
      </div>

      {loading ? <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}><span className="spinner spinner-lg"></span></div> : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {history.length > 0 && (
            <div className="card animate-scale" style={{ padding: 24, marginBottom: 8 }}>
              <h3 style={{ fontSize: 16, fontWeight: 800, marginBottom: 20, color: 'var(--text-primary)' }}>Assessment Trends (Last 12 Months)</h3>
              <div style={{ height: 220, width: '100%' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData} margin={{ top: 0, right: 0, left: 0, bottom: 0 }}>
                    <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fontSize: 12, fill: 'var(--text-muted)' }} />
                    <Tooltip
                      cursor={{ fill: 'rgba(255,255,255,0.04)' }}
                      contentStyle={{ borderRadius: 12, border: '1px solid var(--border)', background: 'var(--bg-card)', color: 'var(--text-primary)', boxShadow: 'var(--shadow-md)', fontWeight: 700 }}
                      formatter={(value) => [value, 'Assessments']}
                    />
                    <Bar dataKey="count" radius={[6, 6, 6, 6]} barSize={32}>
                      {chartData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.severity === 3 ? 'var(--rose)' : entry.severity === 2 ? 'var(--amber)' : 'var(--blue)'} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {history.length === 0 ? (
            <div className="card" style={{ padding: 40, textAlign: 'center' }}>
              <p style={{ color: 'var(--text-muted)' }}>No history available yet.</p>
            </div>
          ) : (
            history.map(a => (
              <div key={a.id} className="card" style={{ overflow: 'hidden' }}>
                <div style={{ padding: '20px 24px', display: 'flex', alignItems: 'center', gap: 16, cursor: 'pointer', background: expandedId === a.id ? 'var(--bg-subtle)' : 'transparent', transition: 'background 0.2s' }} onClick={() => loadDetails(a.id)}>
                  <div style={{ width: 44, height: 44, borderRadius: '50%', background: a.has_feedback ? 'rgba(16,185,129,0.1)' : 'rgba(59,130,246,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: a.has_feedback ? 'var(--green)' : 'var(--blue)' }}>
                    {a.has_feedback ? <CheckCircle size={20} /> : <Clock size={20} />}
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 16, fontWeight: 800 }}>{a.result_message}</div>
                    <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 4 }}>{a.created_at}</div>
                  </div>
                  <button
                    onClick={(e) => deleteAssessment(a.id, e)}
                    title="Delete report"
                    style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, borderRadius: 8, color: 'var(--rose)', display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'background 0.2s' }}
                    onMouseEnter={e => e.currentTarget.style.background = 'rgba(244,63,94,0.1)'}
                    onMouseLeave={e => e.currentTarget.style.background = 'none'}
                  >
                    <Trash2 size={18} />
                  </button>
                  <div style={{ color: 'var(--text-muted)' }}>
                    {expandedId === a.id ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                  </div>
                </div>

                {expandedId === a.id && details[a.id] && (
                  <div style={{ padding: '24px', borderTop: '1px solid var(--border)', background: 'var(--bg-subtle)' }} className="animate-fade">
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
                      <h3 style={{ fontSize: 13, fontWeight: 800, color: 'var(--purple)', textTransform: 'uppercase', margin: 0 }}>Symptom Matrix</h3>
                      <button className="btn btn-ghost btn-sm" onClick={() => handleDownloadReport(a.id, a.result_message, a.created_at)} style={{ gap: 6, padding: '6px 12px', fontSize: 12, display: 'flex', alignItems: 'center' }}>
                        <Download size={14} /> Download Report
                      </button>
                    </div>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 24 }}>
                      {details[a.id].responses.map((r, i) => (
                        <div key={i} style={{ display: 'flex', justifyContent: 'space-between', paddingBottom: 12, borderBottom: '1px solid var(--border-light)' }}>
                          <span style={{ fontSize: 14, fontWeight: 600 }}>{r.symptom_display_name || r.symptom_name}</span>
                          <span className={`badge ${r.response.toLowerCase() === 'yes' ? 'badge-amber' : 'badge-gray'}`}>{r.response}</span>
                        </div>
                      ))}
                    </div>

                    <h3 style={{ fontSize: 13, fontWeight: 800, color: 'var(--blue-light)', textTransform: 'uppercase', marginBottom: 16 }}>Clinical Advice</h3>
                    {advice[a.id]?.length > 0 ? (
                      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                        {advice[a.id].map(adv => (
                          <div key={adv.id} className="advice-bubble">
                            <p style={{ fontSize: 14, fontWeight: 600, marginBottom: 8, color: 'var(--text-primary)' }}>{adv.advice_text}</p>
                            <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--cyan)' }}>DR. {adv.doctor_name?.toUpperCase()}</div>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <p style={{ fontSize: 14, color: 'var(--text-muted)' }}>Pending clinical review.</p>
                    )}
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
}
