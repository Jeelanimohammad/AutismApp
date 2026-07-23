import { X, CheckCircle, AlertTriangle, AlertCircle, Star, Flag, MapPin } from 'lucide-react';

/* Classify each assessment result into a severity tier */
function getSeverityInfo(resultMessage) {
  const msg = (resultMessage || '').toLowerCase();
  if (msg.includes('high') || msg.includes('severe') || msg.includes('critical')) {
    return { color: '#DC2626', light: '#FEF2F2', border: '#FECACA', label: 'High Risk', Icon: AlertCircle };
  }
  if (msg.includes('moderate') || msg.includes('medium')) {
    return { color: '#EA580C', light: '#FFF7ED', border: '#FED7AA', label: 'Moderate', Icon: AlertTriangle };
  }
  if (msg.includes('low') || msg.includes('minimal') || msg.includes('no risk')) {
    return { color: '#16A34A', light: '#F0FDF4', border: '#BBF7D0', label: 'Low Risk', Icon: CheckCircle };
  }
  return { color: '#2563EB', light: '#EFF6FF', border: '#BFDBFE', label: 'Assessed', Icon: Star };
}

export default function JourneyMap({ history, onClose }) {
  const sorted = [...(history || [])].sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

  return (
    <div className="modal-overlay">
      <div className="modal animate-scale" style={{ maxWidth: 640, height: '88vh', display: 'flex', flexDirection: 'column', borderRadius: 28, overflow: 'hidden' }}>

        {/* ── Header ── */}
        <div style={{
          background: 'linear-gradient(135deg, #1D4ED8, #16A34A)',
          padding: '28px 28px 22px',
          position: 'relative', overflow: 'hidden', flexShrink: 0,
        }}>
          {/* Decorative circles */}
          <div style={{ position: 'absolute', top: -40, right: -40, width: 160, height: 160, borderRadius: '50%', background: 'rgba(255,255,255,0.07)', pointerEvents: 'none' }} />
          <div style={{ position: 'absolute', bottom: -20, left: -20, width: 100, height: 100, borderRadius: '50%', background: 'rgba(255,255,255,0.05)', pointerEvents: 'none' }} />

          <div style={{ display: 'flex', alignItems: 'center', gap: 14, position: 'relative', zIndex: 1 }}>
            <div style={{ width: 46, height: 46, borderRadius: 14, background: 'rgba(255,255,255,0.2)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <MapPin size={22} color="white" />
            </div>
            <div style={{ flex: 1 }}>
              <h2 style={{ fontSize: 20, fontWeight: 900, color: 'white', margin: 0 }}>Developmental Journey</h2>
              <button onClick={onClose} style={{ position: 'absolute', top: 24, right: 24, background: 'rgba(255,255,255,0.15)', border: 'none', cursor: 'pointer', borderRadius: 10, padding: 8, color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <X size={20} />
              </button>
              <p style={{ fontSize: 13, color: 'rgba(255,255,255,0.75)', margin: 0, fontWeight: 500 }}>
                {sorted.length} milestone{sorted.length !== 1 ? 's' : ''} recorded
              </p>
            </div>
          </div>

          {/* Progress bar */}
          {sorted.length > 0 && (
            <div style={{ marginTop: 18, position: 'relative', zIndex: 1 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                <span style={{ fontSize: 11, fontWeight: 700, color: 'rgba(255,255,255,0.7)', textTransform: 'uppercase', letterSpacing: 1 }}>Journey Progress</span>
                <span style={{ fontSize: 11, fontWeight: 800, color: 'white' }}>{sorted.length} Complete</span>
              </div>
              <div style={{ height: 6, background: 'rgba(255,255,255,0.2)', borderRadius: 99 }}>
                <div style={{ height: '100%', width: '100%', background: 'rgba(255,255,255,0.85)', borderRadius: 99 }} />
              </div>
            </div>
          )}
        </div>

        {/* ── Body ── */}
        <div style={{ flex: 1, overflowY: 'auto', background: '#F8FAFF', padding: '32px 28px' }}>
          {sorted.length === 0 ? (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', gap: 12 }}>
              <div style={{ width: 80, height: 80, borderRadius: '50%', background: '#EEF2FF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Flag size={32} color="#2563EB" />
              </div>
              <p style={{ fontWeight: 800, fontSize: 16, color: '#1E293B', margin: 0 }}>No Milestones Yet</p>
              <p style={{ fontSize: 14, color: '#64748B', textAlign: 'center', margin: 0 }}>Complete your first assessment to begin the journey.</p>
            </div>
          ) : (
            <div style={{ position: 'relative' }}>

              {/* Gradient spine */}
              <div style={{
                position: 'absolute', left: 27, top: 0, bottom: 0, width: 3,
                background: 'linear-gradient(to bottom, #1D4ED8, #16A34A, #EA580C)',
                borderRadius: 99, opacity: 0.25,
              }} />

              {/* Milestone cards */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
                {sorted.map((assessment, index) => {
                  const { color, light, border, label, Icon } = getSeverityInfo(assessment.result_message);
                  const isLast = index === sorted.length - 1;

                  return (
                    <div key={assessment.id || index} style={{ display: 'flex', gap: 20, alignItems: 'flex-start' }}>

                      {/* Node */}
                      <div style={{ flexShrink: 0, width: 56, display: 'flex', justifyContent: 'center' }}>
                        <div style={{ position: 'relative', width: 56, height: 56 }}>
                          {isLast && (
                            <div style={{
                              position: 'absolute', inset: -6, borderRadius: '50%',
                              border: `2px solid ${color}`, opacity: 0.4,
                              animation: 'jm-pulse 2s ease-in-out infinite',
                            }} />
                          )}
                          <div style={{
                            width: 56, height: 56, borderRadius: '50%',
                            background: light, border: `3px solid ${border}`,
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            boxShadow: `0 4px 14px ${color}30`,
                          }}>
                            <Icon size={22} color={color} />
                          </div>
                        </div>
                      </div>

                      {/* Card */}
                      <div style={{
                        flex: 1, background: '#FFFFFF',
                        border: `1.5px solid ${border}`,
                        borderRadius: 18, padding: '16px 20px',
                        boxShadow: `0 4px 16px ${color}10`,
                        transition: 'transform 0.2s, box-shadow 0.2s',
                        marginBottom: 4,
                      }}
                        onMouseEnter={e => { e.currentTarget.style.transform = 'translateX(5px)'; e.currentTarget.style.boxShadow = `0 8px 24px ${color}22`; }}
                        onMouseLeave={e => { e.currentTarget.style.transform = 'translateX(0)'; e.currentTarget.style.boxShadow = `0 4px 16px ${color}10`; }}
                      >
                        {/* Top row */}
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 10 }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                            <span style={{ fontSize: 11, fontWeight: 900, color: '#FFFFFF', background: color, borderRadius: 99, padding: '3px 10px', letterSpacing: 0.5 }}>
                              STEP {index + 1}
                            </span>
                            {isLast && (
                              <span style={{ fontSize: 11, fontWeight: 700, color: '#16A34A', background: '#DCFCE7', padding: '3px 8px', borderRadius: 99, border: '1px solid #BBF7D0' }}>
                                ● Latest
                              </span>
                            )}
                          </div>
                          <span style={{ fontSize: 11, fontWeight: 700, color: '#94A3B8', fontFamily: 'monospace' }}>
                            {assessment.created_at?.substring(0, 10)}
                          </span>
                        </div>

                        {/* Result text */}
                        <div style={{ fontSize: 15, fontWeight: 800, color: '#0F172A', marginBottom: 10, lineHeight: 1.4 }}>
                          {assessment.result_message}
                        </div>

                        {/* Bottom row */}
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                            <div style={{ width: 8, height: 8, borderRadius: '50%', background: color, flexShrink: 0 }} />
                            <span style={{ fontSize: 12, fontWeight: 700, color }}>{label}</span>
                          </div>
                          <span style={{ fontSize: 11, color: '#94A3B8', fontWeight: 600 }}>
                            {assessment.created_at?.substring(11, 16) || ''}
                          </span>
                        </div>
                      </div>
                    </div>
                  );
                })}

                {/* Finish flag */}
                <div style={{ display: 'flex', gap: 20, alignItems: 'center', opacity: 0.45, paddingTop: 4 }}>
                  <div style={{ width: 56, flexShrink: 0, display: 'flex', justifyContent: 'center' }}>
                    <div style={{ width: 32, height: 32, borderRadius: '50%', background: '#E2E8F0', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <Flag size={14} color="#94A3B8" />
                    </div>
                  </div>
                  <span style={{ fontSize: 12, fontWeight: 700, color: '#94A3B8', fontStyle: 'italic' }}>Your journey continues…</span>
                </div>
              </div>

              <style>{`
                @keyframes jm-pulse {
                  0%, 100% { opacity: 0.4; transform: scale(1); }
                  50% { opacity: 0.8; transform: scale(1.18); }
                }
              `}</style>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

