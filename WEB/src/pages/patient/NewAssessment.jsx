import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Activity, ArrowRight, Baby, Accessibility, CheckCircle, Shield, XCircle, ImageIcon, PlayCircle, FileText, ArrowLeft, Heart } from 'lucide-react';
import { api } from '../../api/api';
import { useAuth } from '../../context/AuthContext';

export default function NewAssessment() {
  const { patient } = useAuth();
  const navigate = useNavigate();
  const [phase, setPhase] = useState('welcome'); // 'welcome' | 'age-select' | 'assessment' | 'submission-success' | 'result'
  
  // Selection/Assessment state
  const [selectedAgeGroup, setSelectedAgeGroup] = useState(null); // '<3' or '>3'
  const [symptoms, setSymptoms] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const [currentIndex, setCurrentIndex] = useState(0);
  const [responses, setResponses] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const [resultMessage, setResultMessage] = useState('');

  // 1. Start Assessment - moves to Age Selection
  const handleBegin = () => {
    setPhase('age-select');
  };

  // 2. Fetch symptoms based on selected age bracket
  const startSymptomTracking = async () => {
    if (!selectedAgeGroup) return;
    setLoading(true);
    setError('');
    
    // Map age group to typical age value for the API
    const ageValue = selectedAgeGroup === '<3' ? 2 : 4;
    
    try {
      const res = await api.getSymptoms(ageValue, patient.patient_id);
      const symptomsList = res.data || res.symptoms || [];
      if (res.success && symptomsList.length > 0) {
        setSymptoms(symptomsList);
        setCurrentIndex(0);
        setResponses({});
        setPhase('assessment');
      } else {
        setError('No symptoms found for this age group.');
      }
    } catch {
      setError('Connection error. Failed to load assessment.');
    } finally {
      setLoading(false);
    }
  };

  // 3. Handle YES / NO answers
  const handleAnswer = async (answer) => {
    const currentSymptom = symptoms[currentIndex];
    const newResponses = { ...responses, [currentSymptom.symptom_name]: answer };
    setResponses(newResponses);

    if (currentIndex < symptoms.length - 1) {
      setCurrentIndex(currentIndex + 1);
    } else {
      // Complete Assessment & Submit
      setSubmitting(true);
      setError('');
      try {
        const ageValue = selectedAgeGroup === '<3' ? 2 : 4;
        const responseList = Object.entries(newResponses).map(([name, ans]) => ({
          symptom_name: name,
          response: ans
        }));
        
        const res = await api.submitResponses(patient.patient_id, ageValue, responseList);
        if (res.success) {
          setResultMessage(res.result_message);
          setPhase('submission-success');
        } else {
          setError(res.message || 'Submission failed.');
        }
      } catch {
        setError('Failed to submit assessment answers.');
      } finally {
        setSubmitting(false);
      }
    }
  };

  // Helper for age group cards
  const ageOptions = [
    {
      value: '<3',
      title: 'Infant & Toddler',
      subtitle: 'Under 3 Years Old',
      icon: Baby,
      gradient: 'linear-gradient(135deg, var(--purple), var(--blue))',
      shadow: '0 8px 20px rgba(139, 92, 246, 0.3)'
    },
    {
      value: '>3',
      title: 'Older Child',
      subtitle: '3 Years and Older',
      icon: Accessibility,
      gradient: 'linear-gradient(135deg, var(--blue), var(--cyan))',
      shadow: '0 8px 20px rgba(59, 130, 246, 0.3)'
    }
  ];

  // AI Scoring details derived from responses
  const getAIScores = () => {
    const yesCount = Object.values(responses).filter(r => r === 'Yes').length;
    const totalCount = symptoms.length;
    let riskLevel = 'Low';
    if (yesCount >= 5) riskLevel = 'High';
    else if (yesCount >= 2) riskLevel = 'Moderate';

    const recommendation = yesCount >= 3 
      ? 'The pattern suggests strong behavioral indicators. Professional consultation is recommended.'
      : 'The pattern suggests mild or low indicators. Continued monitoring is advised.';

    return { yesCount, totalCount, riskLevel, recommendation };
  };

  // ==========================================
  // PHASE 1: WELCOME SCREEN
  // ==========================================
  if (phase === 'welcome') {
    return (
      <div className="page-center animate-fade" style={{ flexDirection: 'column', padding: '40px 24px' }}>
        <div style={{ textAlign: 'center', maxWidth: 480, width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 28 }}>
          
          <div style={{
            width: 80, height: 80, borderRadius: '50%', background: 'rgba(255,255,255,0.05)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: 'var(--shadow-md)', border: '1px solid rgba(255, 255, 255, 0.1)'
          }}>
            <Activity size={34} style={{ color: 'var(--cyan)' }} />
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <h1 style={{ fontSize: 32, fontWeight: 900, color: 'var(--text-primary)' }}>
              Behaviour Analysis
            </h1>
            <p style={{ fontSize: 15, fontWeight: 700, color: 'var(--text-secondary)', lineHeight: 1.5, padding: '0 16px' }}>
              Understand your child's behavior with simple guided tools and insights.
            </p>
          </div>

          <button
            onClick={handleBegin}
            style={{
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
              width: '100%', height: 60, borderRadius: 18, border: 'none', cursor: 'pointer',
              background: 'linear-gradient(90deg, var(--cyan), var(--blue))', color: '#FFFFFF',
              fontSize: 15, fontWeight: 900, letterSpacing: '1.2px',
              boxShadow: '0 10px 25px rgba(6, 182, 212, 0.35)', transition: 'all 0.2s'
            }}
            onMouseEnter={e => e.currentTarget.style.transform = 'scale(1.02)'}
            onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}
          >
            BEGIN ANALYSIS <ArrowRight size={18} />
          </button>
        </div>
      </div>
    );
  }

  // ==========================================
  // PHASE 2: AGE BRACKET SELECTION
  // ==========================================
  if (phase === 'age-select') {
    return (
      <div className="page-center animate-fade" style={{ flexDirection: 'column', padding: '40px 24px' }}>
        <div style={{ maxWidth: 480, width: '100%', display: 'flex', flexDirection: 'column', gap: 32 }}>
          
          <div style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            <div style={{
              width: 64, height: 64, borderRadius: '50%',
              background: 'linear-gradient(135deg, var(--blue), var(--cyan))',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 10px 20px rgba(59, 130, 246, 0.2)'
            }}>
              <Baby size={28} color="white" />
            </div>
            
            <h1 style={{ fontSize: 30, fontWeight: 900, color: 'var(--text-primary)', marginTop: 8 }}>
              Select Age Group
            </h1>
            <p style={{ fontSize: 14, fontWeight: 700, color: 'var(--text-secondary)' }}>
              Choose the respective age bracket to ensure clinical alignment.
            </p>
          </div>

          {error && (
            <div className="alert alert-error">
              <Shield size={16} /> <span>{error}</span>
            </div>
          )}

          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {ageOptions.map(opt => {
              const isSelected = selectedAgeGroup === opt.value;
              const OptIcon = opt.icon;
              return (
                <div
                  key={opt.value}
                  onClick={() => setSelectedAgeGroup(opt.value)}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 16, padding: 18,
                    borderRadius: 22, border: isSelected ? '2px solid var(--blue)' : '1px solid var(--border)',
                    background: 'var(--bg-card)', cursor: 'pointer', transition: 'all 0.2s',
                    boxShadow: isSelected ? opt.shadow : 'none',
                    transform: isSelected ? 'scale(1.02)' : 'none'
                  }}
                >
                  <div style={{
                    width: 50, height: 50, borderRadius: 12, background: opt.gradient,
                    display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#FFFFFF'
                  }}>
                    <OptIcon size={22} />
                  </div>

                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 4 }}>
                    <span style={{ fontSize: 18, fontWeight: 900, color: 'var(--text-primary)' }}>{opt.title}</span>
                    <span style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-secondary)' }}>{opt.subtitle}</span>
                  </div>

                  <div style={{
                    width: 22, height: 22, borderRadius: '50%',
                    border: `2px solid ${isSelected ? 'var(--blue)' : 'var(--border)'}`,
                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                  }}>
                    {isSelected && <div style={{ width: 12, height: 12, borderRadius: '50%', background: 'var(--blue)' }} />}
                  </div>
                </div>
              );
            })}
          </div>

          <button
            onClick={startSymptomTracking}
            disabled={!selectedAgeGroup || loading}
            style={{
              width: '100%', height: 56, borderRadius: 18, border: 'none',
              background: !selectedAgeGroup ? 'rgba(255, 255, 255, 0.05)' : 'linear-gradient(135deg, var(--blue), var(--cyan))',
              color: !selectedAgeGroup ? 'rgba(255, 255, 255, 0.3)' : '#FFFFFF',
              fontSize: 16, fontWeight: 900, cursor: !selectedAgeGroup ? 'not-allowed' : 'pointer',
              marginTop: 16, boxShadow: selectedAgeGroup ? '0 10px 25px rgba(59, 130, 246, 0.3)' : 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'center'
            }}
          >
            {loading ? <span className="spinner" style={{ borderTopColor: 'white' }} /> : 'Continue'}
          </button>
        </div>
      </div>
    );
  }

  // ==========================================
  // PHASE 3: INTERACTIVE QUESTIONNAIRE
  // ==========================================
  if (phase === 'assessment') {
    const current = symptoms[currentIndex];
    const progress = ((currentIndex + 1) / symptoms.length);

    return (
      <div className="page-center animate-fade" style={{ flexDirection: 'column', justifyContent: 'flex-start', paddingTop: 40, paddingBottom: 40 }}>
        <div style={{ maxWidth: 520, width: '100%', padding: '0 16px' }}>
          
          {/* Progress Header */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8, marginBottom: 24 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13, fontWeight: 700, color: 'var(--text-muted)' }}>
              <span>Question {currentIndex + 1} of {symptoms.length}</span>
              <span>{Math.round(progress * 100)}% Complete</span>
            </div>
            
            <div style={{ height: 8, background: 'rgba(255,255,255,0.05)', borderRadius: 4, overflow: 'hidden' }}>
              <div style={{
                height: '100%',
                background: 'linear-gradient(90deg, var(--cyan), var(--blue))',
                width: `${progress * 100}%`,
                transition: 'width 0.4s cubic-bezier(0.1, 0.8, 0.25, 1)'
              }} />
            </div>
          </div>

          {error && (
            <div className="alert alert-error" style={{ marginBottom: 20 }}>
              <Shield size={16} /> <span>{error}</span>
            </div>
          )}

          {/* Assessment Card */}
          <div className="card animate-scale" style={{ padding: '32px 24px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24, textAlign: 'center' }}>
            
            {/* Image Box */}
            <div style={{
              width: '100%', height: 230, borderRadius: 16, overflow: 'hidden',
              background: 'var(--bg-subtle)', border: '1px solid var(--border-light)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative'
            }}>
              {current ? (
                <img
                  src={api.resolveImageUrl(current.image_url) || `/symptoms/child${current.id}.png`}
                  alt={current.symptom_name}
                  style={{ width: '100%', height: '100%', objectFit: 'contain' }}
                  onError={(e) => {
                    const fallbackSrc = `${window.location.origin}/symptoms/child${current.id}.png`;
                    if (e.target.src !== fallbackSrc) {
                      e.target.src = fallbackSrc;
                    } else {
                      e.target.style.display = 'none';
                      if (e.target.nextSibling) {
                        e.target.nextSibling.style.display = 'flex';
                      }
                    }
                  }}
                />
              ) : null}
              
              <div style={{
                display: current?.image_url ? 'none' : 'flex',
                flexDirection: 'column', alignItems: 'center', gap: 10, color: 'var(--text-muted)'
              }}>
                <ImageIcon size={48} strokeWidth={1.5} />
                <span style={{ fontSize: 13, fontWeight: 600 }}>Medical visual loading...</span>
              </div>
            </div>

            {/* Symptom Name Capsule under the Image */}
            <div style={{
              background: 'rgba(255,255,255,0.05)', padding: '10px 20px', borderRadius: 12,
              fontSize: 14, fontWeight: 700, color: 'var(--text-primary)',
              border: '1px solid var(--border)', maxWidth: '90%'
            }}>
              {current?.symptom_name}
            </div>

            {/* Exhibit symptom card */}
            <div style={{
              width: '100%', background: 'rgba(0,0,0,0.2)', padding: '18px 12px', borderRadius: 16,
              border: '1px solid var(--border)', fontSize: 18, fontWeight: 800, color: 'var(--text-primary)'
            }}>
              Does the child exhibit this symptom?
            </div>

            {/* YES / NO iOS Styled Buttons */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, width: '100%', marginTop: 8 }}>
              <button
                onClick={() => handleAnswer('Yes')}
                disabled={submitting}
                style={{
                  height: 52, borderRadius: 15, border: 'none', background: 'var(--green)',
                  color: 'white', fontSize: 16, fontWeight: 900, cursor: 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                  boxShadow: '0 4px 12px rgba(16, 185, 129, 0.2)'
                }}
              >
                <CheckCircle size={18} /> YES
              </button>

              <button
                onClick={() => handleAnswer('No')}
                disabled={submitting}
                style={{
                  height: 52, borderRadius: 15, border: 'none', background: 'var(--rose)',
                  color: 'white', fontSize: 16, fontWeight: 900, cursor: 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                  boxShadow: '0 4px 12px rgba(244, 63, 94, 0.2)'
                }}
              >
                <XCircle size={18} /> NO
              </button>
            </div>

            {submitting && (
              <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 8 }}>
                <span className="spinner" />
                <span style={{ fontSize: 13, color: 'var(--text-muted)', fontWeight: 600 }}>Analyzing responses...</span>
              </div>
            )}
          </div>

          {/* Previous Question navigation fallback */}
          {currentIndex > 0 && (
            <button
              onClick={() => setCurrentIndex(currentIndex - 1)}
              style={{
                background: 'transparent', border: 'none', cursor: 'pointer',
                color: 'var(--text-muted)', fontWeight: 700, fontSize: 14,
                display: 'flex', alignItems: 'center', gap: 6, margin: '20px auto 0'
              }}
            >
              Previous Question
            </button>
          )}
        </div>
      </div>
    );
  }

  // ==========================================
  // PHASE 4: SUBMISSION SCREEN
  // ==========================================
  if (phase === 'submission-success') {
    return (
      <div className="page-center animate-fade" style={{ flexDirection: 'column', padding: '40px 24px' }}>
        <div style={{
          background: 'var(--bg-card)',
          padding: '40px 32px', borderRadius: 24, textAlign: 'center', maxWidth: 460, width: '100%',
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24,
          boxShadow: 'var(--shadow-lg)', border: '1px solid var(--border)'
        }} className="animate-scale">
          
          {/* Blue Success Checkmark Icon */}
          <div style={{
            width: 100, height: 100, borderRadius: '50%', background: 'rgba(59, 130, 246, 0.1)',
            display: 'flex', alignItems: 'center', justifyContent: 'center'
          }}>
            <div style={{
              width: 60, height: 60, borderRadius: '50%',
              background: 'linear-gradient(to bottom, var(--cyan), var(--blue))',
              display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#FFFFFF'
            }}>
              <CheckCircle size={36} strokeWidth={2.5} />
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <h2 style={{ fontSize: 24, fontWeight: 900, color: 'var(--text-primary)' }}>
              Responses Saved Successfully
            </h2>
            <p style={{ fontSize: 15, fontWeight: 600, color: 'var(--text-secondary)', lineHeight: 1.5, padding: '0 16px' }}>
              Your assessment has been submitted. You can now view the details below.
            </p>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, width: '100%', marginTop: 12 }}>
            <button
              onClick={() => setPhase('result')}
              style={{
                width: '100%', height: 52, borderRadius: 12, border: 'none', cursor: 'pointer',
                background: 'linear-gradient(90deg, var(--cyan), var(--blue))', color: '#FFFFFF',
                fontSize: 16, fontWeight: 900, boxShadow: '0 4px 12px rgba(59, 130, 246, 0.3)'
              }}
            >
              View Result
            </button>

            <button
              onClick={() => navigate('/patient/home', { state: { refreshed: Date.now() } })}
              style={{
                width: '100%', height: 52, borderRadius: 12, border: '2px solid var(--blue)',
                background: 'transparent', color: 'var(--blue)', fontSize: 16, fontWeight: 900, cursor: 'pointer'
              }}
            >
              Back to Home
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ==========================================
  // PHASE 5: DETAILED RESULTS SCREEN
  // ==========================================
  if (phase === 'result') {
    const { yesCount, totalCount, riskLevel, recommendation } = getAIScores();

    return (
      <div className="page-center animate-fade" style={{ flexDirection: 'column', justifyContent: 'flex-start', padding: '0 0 40px' }}>
        
        {/* Banner Header */}
        <div style={{
          width: '100%', background: 'linear-gradient(135deg, var(--blue), var(--cyan))',
          padding: '24px 20px', textAlign: 'center', display: 'flex', flexDirection: 'column', gap: 6,
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.3)', color: '#FFFFFF'
        }}>
          <h1 style={{ fontSize: 22, fontWeight: 900, margin: 0 }}>Assessment Result</h1>
          <p style={{ fontSize: 13, opacity: 0.8, fontWeight: 700, margin: 0 }}>Review the analysis below</p>
        </div>

        <div style={{ maxWidth: 480, width: '100%', padding: '24px 20px', display: 'flex', flexDirection: 'column', gap: 24 }}>
          
          {/* Main White Analysis Card */}
          <div className="card animate-scale" style={{ padding: '32px 24px', display: 'flex', flexDirection: 'column', gap: 24 }}>
            
            {/* Top Accent line */}
            <div style={{ width: 50, height: 4, borderRadius: 2, background: 'var(--blue)', margin: '0 auto' }} />

            {/* 1. Clinical Result Section */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10, textAlign: 'center' }}>
              <h3 style={{ fontSize: 17, fontWeight: 900, color: 'var(--green)', margin: 0 }}>Clinical Result</h3>
              <div style={{
                background: 'rgba(16, 185, 129, 0.1)', padding: '16px', borderRadius: 12,
                fontSize: 14, fontWeight: 700, color: 'var(--green)', lineHeight: 1.5
              }}>
                {resultMessage || "Your child may require further diagnostic evaluation."}
              </div>
            </div>

            <hr style={{ border: '0', borderTop: '1px solid var(--border)', margin: 0 }} />

            {/* 2. AI Summary Section */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              <h3 style={{ fontSize: 17, fontWeight: 900, color: 'var(--cyan)', margin: 0, textAlign: 'center' }}>AI Summary</h3>
              
              <div style={{
                background: 'rgba(255, 255, 255, 0.05)', padding: '18px 16px', borderRadius: 16,
                display: 'flex', flexDirection: 'column', gap: 10, fontSize: 14, fontWeight: 700, color: 'var(--text-primary)'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span style={{ color: 'var(--cyan)' }}>•</span>
                  <span>Screening Score: {yesCount} / {totalCount}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span style={{ color: 'var(--cyan)' }}>•</span>
                  <span>Indicators Detected: {yesCount}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span style={{ color: 'var(--cyan)' }}>•</span>
                  <span>Risk Level: <span style={{ color: riskLevel === 'High' ? 'var(--rose)' : riskLevel === 'Moderate' ? 'var(--amber)' : 'var(--green)' }}>{riskLevel}</span></span>
                </div>

                <p style={{
                  fontSize: 12, color: 'var(--text-secondary)', fontWeight: 600, lineHeight: 1.4,
                  borderTop: '1px solid var(--border)', paddingTop: 10, marginTop: 4, marginBottom: 0
                }}>
                  {recommendation}
                </p>
              </div>
            </div>
          </div>

          {/* Close Action Button */}
          <button
            onClick={() => navigate('/patient/home', { state: { refreshed: Date.now() } })}
            style={{
              width: '100%', height: 52, borderRadius: 26, border: 'none', cursor: 'pointer',
              background: 'linear-gradient(90deg, var(--blue), var(--cyan))', color: '#FFFFFF',
              fontSize: 16, fontWeight: 900, boxShadow: '0 8px 20px rgba(6, 182, 212, 0.25)',
              marginTop: 10
            }}
          >
            Close
          </button>
        </div>
      </div>
    );
  }

  return null;
}
