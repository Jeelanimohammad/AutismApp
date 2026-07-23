import { useEffect, useState, useRef } from 'react';
import { CheckCircle, XCircle, AlertCircle, X, Info, Undo2 } from 'lucide-react';

// Simple global toast system
let toastQueue = [];
let listeners = [];

function notify(listeners) {
  listeners.forEach(fn => fn([...toastQueue]));
}

export const toast = {
  show(message, type = 'info', duration = 3500, options = {}) {
    const id = Date.now() + Math.random();
    toastQueue.push({ id, message, type, duration, ...options });
    notify(listeners);
    setTimeout(() => {
      toastQueue = toastQueue.filter(t => t.id !== id);
      notify(listeners);
    }, duration + 400);
    return id;
  },
  success(msg, dur) { return this.show(msg, 'success', dur); },
  error(msg, dur) { return this.show(msg, 'error', dur || 4500); },
  warning(msg, dur) { return this.show(msg, 'warning', dur); },
  info(msg, dur) { return this.show(msg, 'info', dur); },
  /** Show a warning toast with an Undo button. Returns the toast id. */
  undoable(msg, onUndo, duration = 5000) {
    return this.show(msg, 'warning', duration, { actionLabel: 'Undo', onAction: onUndo });
  },
  dismiss(id) {
    toastQueue = toastQueue.filter(t => t.id !== id);
    notify(listeners);
  },
};

const icons = {
  success: <CheckCircle size={18} />,
  error: <XCircle size={18} />,
  warning: <AlertCircle size={18} />,
  info: <Info size={18} />,
};

const colors = {
  success: { bg: '#ECFDF5', border: '#6EE7B7', text: '#065F46', icon: '#10B981' },
  error:   { bg: '#FEF2F2', border: '#FCA5A5', text: '#991B1B', icon: '#EF4444' },
  warning: { bg: '#FFFBEB', border: '#FCD34D', text: '#92400E', icon: '#F59E0B' },
  info:    { bg: '#EFF6FF', border: '#BFDBFE', text: '#1E40AF', icon: '#3B82F6' },
};

function ToastItem({ id, message, type, duration, actionLabel, onAction, onRemove }) {
  const [visible, setVisible] = useState(false);
  const [leaving, setLeaving] = useState(false);
  const actionFired = useRef(false);
  const c = colors[type] || colors.info;

  const dismiss = () => {
    if (leaving) return;
    setLeaving(true);
    setTimeout(() => onRemove(id), 350);
  };

  useEffect(() => {
    requestAnimationFrame(() => setVisible(true));
    const t = setTimeout(() => dismiss(), duration);
    return () => clearTimeout(t);
  }, []);

  const handleAction = (e) => {
    e.stopPropagation();
    if (actionFired.current) return;
    actionFired.current = true;
    if (onAction) onAction();
    dismiss();
  };

  return (
    <div
      onClick={() => { if (!actionLabel) dismiss(); }}
      style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '14px 16px',
        background: c.bg,
        border: `1px solid ${c.border}`,
        borderRadius: 14,
        boxShadow: '0 8px 32px rgba(0,0,0,0.12), 0 2px 8px rgba(0,0,0,0.06)',
        cursor: actionLabel ? 'default' : 'pointer',
        minWidth: 300, maxWidth: 440,
        transition: 'all 0.35s cubic-bezier(0.34,1.56,0.64,1)',
        transform: visible && !leaving ? 'translateX(0) scale(1)' : 'translateX(120%) scale(0.9)',
        opacity: visible && !leaving ? 1 : 0,
        userSelect: 'none',
      }}
    >
      <span style={{ color: c.icon, flexShrink: 0, marginTop: 1 }}>{icons[type]}</span>
      <span style={{ flex: 1, fontSize: 14, fontWeight: 600, color: c.text, lineHeight: 1.4 }}>{message}</span>

      {actionLabel && (
        <button
          onClick={handleAction}
          style={{
            background: c.icon,
            color: '#fff',
            border: 'none',
            borderRadius: 8,
            padding: '6px 14px',
            fontSize: 13,
            fontWeight: 800,
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: 5,
            whiteSpace: 'nowrap',
            flexShrink: 0,
            transition: 'opacity 0.2s',
          }}
          onMouseEnter={e => e.currentTarget.style.opacity = '0.85'}
          onMouseLeave={e => e.currentTarget.style.opacity = '1'}
        >
          <Undo2 size={13} />
          {actionLabel}
        </button>
      )}

      <X
        size={14}
        style={{ color: c.icon, opacity: 0.6, flexShrink: 0, marginTop: 2, cursor: 'pointer' }}
        onClick={(e) => { e.stopPropagation(); dismiss(); }}
      />
    </div>
  );
}

export default function ToastContainer() {
  const [toasts, setToasts] = useState([]);

  useEffect(() => {
    const fn = (list) => setToasts(list);
    listeners.push(fn);
    return () => { listeners = listeners.filter(l => l !== fn); };
  }, []);

  const remove = (id) => {
    toastQueue = toastQueue.filter(t => t.id !== id);
    notify(listeners);
  };

  if (toasts.length === 0) return null;

  return (
    <div style={{
      position: 'fixed', top: 20, right: 20, zIndex: 9999,
      display: 'flex', flexDirection: 'column', gap: 10,
      pointerEvents: 'none',
    }}>
      {toasts.map(t => (
        <div key={t.id} style={{ pointerEvents: 'auto' }}>
          <ToastItem {...t} onRemove={remove} />
        </div>
      ))}
    </div>
  );
}
