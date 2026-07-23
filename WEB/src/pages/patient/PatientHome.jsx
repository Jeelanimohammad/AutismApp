import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { api } from '../../api/api';
import { Activity, MessageSquare, PlusCircle, ArrowRightCircle, Sun, Moon, Sunrise, HeartPulse, ShieldAlert, AlertTriangle } from 'lucide-react';
import JourneyMap from './JourneyMap';

export default function PatientHome() {
  const { patient } = useAuth();
  const navigate = useNavigate();

  const [assessmentCount, setAssessmentCount] = useState(0);
  const [reportCount, setReportCount] = useState(0);
  const [latestFeedback, setLatestFeedback] = useState('No feedback yet.');
  const [isLoading, setIsLoading] = useState(true);
  const [showJourney, setShowJourney] = useState(false);
  const [history, setHistory] = useState([]);
  const [isHighRisk, setIsHighRisk] = useState(false);

  const getGreeting = () => {
    const hr = new Date().getHours();
    if (hr < 12) return { text: 'GOOD MORNING', icon: Sunrise, color: '#FCD34D' };
    if (hr < 17) return { text: 'GOOD AFTERNOON', icon: Sun, color: 'var(--blue)' };
    return { text: 'GOOD EVENING', icon: Moon, color: 'var(--purple)' };
  };

  const greeting = getGreeting();

  useEffect(() => {
    if (!patient?.patient_id) return;
    setIsLoading(true);
    Promise.all([
      api.getAssessments(patient.patient_id).catch(() => []),
      api.getAdvice(patient.patient_id).catch(() => ({ advice: [] }))
    ]).then(([asmtRes, adviceRes]) => {
      const assessments = Array.isArray(asmtRes) ? asmtRes : (asmtRes.assessments || []);
      const advice = Array.isArray(adviceRes) ? adviceRes : (adviceRes.advice || []);

      setAssessmentCount(assessments.length);
      setReportCount(assessments.filter(a => a.has_feedback === 1 || a.has_feedback === '1').length);
      setHistory(assessments);
      // check if the latest assessment is high-risk
      const latest = assessments[0];
      const latestResult = (latest?.result_message || '').toLowerCase();
      setIsHighRisk(latestResult.match(/high|severe|critical/) !== null);

      if (advice.length > 0) {
        setLatestFeedback(advice[0].advice_text);
      } else {
        setLatestFeedback('No feedback yet.');
      }
      setIsLoading(false);
    });
  }, [patient?.patient_id]);

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-full">
        <div className="spinner spinner-lg"></div>
      </div>
    );
  }

  const ratio = assessmentCount > 0 ? (reportCount / assessmentCount) * 100 : 0;

  return (
    <div className="animate-fade" style={{ maxWidth: 800, margin: '0 auto' }}>
      
      {/* Red High-Risk Alert Banner */}
      {isHighRisk && (
        <div style={{
          background: 'linear-gradient(135deg, #FEF2F2, #FFF1F2)',
          border: '1.5px solid #FECACA', borderRadius: 16, padding: '16px 20px',
          marginBottom: 24, display: 'flex', alignItems: 'center', gap: 14,
          boxShadow: '0 4px 16px rgba(220,38,38,0.1)'
        }}>
          <div style={{ width: 42, height: 42, borderRadius: '50%', background: '#DC2626', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, animation: 'phRedPulse 2s ease-in-out infinite' }}>
            <ShieldAlert size={20} color="white" />
          </div>
          <div>
            <div style={{ fontSize: 14, fontWeight: 900, color: '#991B1B', marginBottom: 2 }}>High-Risk Assessment Detected</div>
            <div style={{ fontSize: 12, color: '#B91C1C', fontWeight: 500 }}>Your child's latest result indicates elevated risk. Please consult your doctor immediately.</div>
          </div>
        </div>
      )}

      {/* Greeting Header */}
      <div style={{ marginBottom: 32 }}>
        <div className="flex items-center gap-2" style={{ marginBottom: 8 }}>
          <greeting.icon size={18} color={greeting.color} />
          <span style={{ fontSize: 13, fontWeight: 700, letterSpacing: 1.5, color: 'var(--text-secondary)' }}>
            {greeting.text}
          </span>
        </div>
        <h1 style={{ fontSize: 32, fontWeight: 900, marginBottom: 4 }}>
          Hello, {patient?.name || '...'}!
        </h1>
        <p style={{ fontSize: 16, fontWeight: 600, color: 'var(--text-muted)' }}>
          Child Progress Summary
        </p>
      </div>

      {/* Stats Row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 24 }}>
        <div className="card" style={{ padding: 20, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: 'linear-gradient(135deg, var(--blue), var(--blue-light))', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white' }}>
            <Activity size={24} />
          </div>
          <div>
            <div style={{ fontSize: 32, fontWeight: 800, lineHeight: 1 }}>{assessmentCount}</div>
            <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--text-secondary)', marginTop: 4 }}>Assessments</div>
          </div>
        </div>

        <div className="card" style={{ padding: 20, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: 'linear-gradient(135deg, var(--cyan), var(--cyan-light))', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white' }}>
            <MessageSquare size={24} />
          </div>
          <div>
            <div style={{ fontSize: 32, fontWeight: 800, lineHeight: 1 }}>{reportCount}</div>
            <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--text-secondary)', marginTop: 4 }}>Feedbacks</div>
          </div>
        </div>
      </div>

      {/* Progress Tile */}
      <div className="card" style={{ padding: 24, marginBottom: 24, border: isHighRisk ? '1.5px solid #FECACA' : undefined }}>
        <div className="flex justify-between items-center" style={{ marginBottom: 16 }}>
          <div className="flex items-center gap-2">
            <HeartPulse size={18} color={isHighRisk ? '#DC2626' : 'var(--pink-light)'} />
            <span style={{ fontSize: 15, fontWeight: 800 }}>Monitoring Status</span>
          </div>
          <div className={isHighRisk ? '' : 'badge badge-green'} style={isHighRisk ? { display: 'flex', alignItems: 'center', gap: 5, fontSize: 11, fontWeight: 800, color: '#DC2626', background: '#FEF2F2', padding: '4px 10px', borderRadius: 99, border: '1px solid #FECACA' } : {}}>
            {isHighRisk ? <><AlertTriangle size={12} /> URGENT</> : 'ACTIVE'}
          </div>
        </div>

        {isHighRisk && (
          <div style={{ fontSize: 12, fontWeight: 700, color: '#DC2626', background: '#FEF2F2', borderRadius: 10, padding: '8px 12px', marginBottom: 12, display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#DC2626', flexShrink: 0, animation: 'phRedPulse 1.5s ease-in-out infinite', display: 'inline-block' }} />
            High-risk result detected — seek professional help immediately
          </div>
        )}

        <div className="flex justify-between items-center" style={{ marginBottom: 8 }}>
          <span style={{ fontSize: 13, color: 'var(--text-secondary)', fontWeight: 500 }}>Doctor Reviews Complete</span>
          <span style={{ fontSize: 12, fontWeight: 700, color: 'var(--blue-light)', cursor: 'pointer' }} onClick={() => setShowJourney(true)}>View Roadmap</span>
        </div>

        <div style={{ width: '100%', height: 8, background: 'rgba(255,255,255,0.08)', borderRadius: 4, overflow: 'hidden' }}>
          <div style={{ width: `${ratio}%`, height: '100%', background: isHighRisk ? 'linear-gradient(90deg, #DC2626, #EF4444)' : 'linear-gradient(90deg, var(--cyan), var(--blue))', transition: 'width 1s ease' }} />
        </div>
      </div>

      {/* Feedback Card */}
      <div className="card" style={{ padding: 24, marginBottom: 24 }}>
        <div className="flex justify-between items-center" style={{ marginBottom: 16 }}>
          <div className="flex items-center gap-2">
            <MessageSquare size={18} color="var(--purple-light)" />
            <span style={{ fontSize: 15, fontWeight: 800 }}>Latest Doctor Feedback</span>
          </div>
        </div>
        
        <div className="flex gap-3" style={{ background: 'rgba(255,255,255,0.04)', padding: 16, borderRadius: 12, border: '1px solid var(--border)' }}>
          <div style={{ width: 4, background: 'linear-gradient(180deg, var(--cyan), var(--blue))', borderRadius: 4 }} />
          <p style={{ fontSize: 15, lineHeight: 1.5, fontStyle: 'italic', color: 'var(--text-primary)', margin: 0 }}>
            "{latestFeedback}"
          </p>
        </div>
      </div>

      {/* New Assessment CTA */}
      <div 
        onClick={() => navigate('/patient/assess')}
        style={{
          background: 'linear-gradient(135deg, #0D9488, #0EA5E9)',
          borderRadius: 24, padding: 24, cursor: 'pointer',
          color: 'white', display: 'flex', alignItems: 'center', gap: 20,
          boxShadow: '0 10px 30px rgba(13,148,136,0.25)',
          transition: 'transform 0.2s',
          border: '1px solid rgba(255,255,255,0.1)'
        }}
        onMouseEnter={e => e.currentTarget.style.transform = 'scale(1.02)'}
        onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}
      >
        <div style={{ width: 56, height: 56, borderRadius: '50%', background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <PlusCircle size={32} />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 20, fontWeight: 900, marginBottom: 4 }}>New Assessment</div>
          <div style={{ fontSize: 14, opacity: 0.9, fontWeight: 500 }}>Start a new symptom evaluation</div>
        </div>
        <ArrowRightCircle size={32} opacity={0.9} />
      </div>

      {showJourney && <JourneyMap history={history} onClose={() => setShowJourney(false)} />}

      <style>{`
        @keyframes phRedPulse {
          0%, 100% { box-shadow: 0 0 0 0 rgba(220,38,38,0.45); }
          50% { box-shadow: 0 0 0 8px rgba(220,38,38,0); }
        }
      `}</style>
    </div>
  );
}
