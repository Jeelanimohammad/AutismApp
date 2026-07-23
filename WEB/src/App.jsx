import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import ToastContainer from './components/Toast';

import RoleSelection from './pages/RoleSelection';
import DoctorLogin from './pages/auth/DoctorLogin';
import PatientLogin from './pages/auth/PatientLogin';
import RegisterDoctor from './pages/auth/RegisterDoctor';
import RegisterPatient from './pages/auth/RegisterPatient';
import ForgotPassword from './pages/auth/ForgotPassword';

import DoctorDashboard from './pages/doctor/DoctorDashboard';
import PatientDashboard from './pages/patient/PatientDashboard';

function ProtectedDoctor({ children }) {
  const { doctor } = useAuth();
  return doctor ? children : <Navigate to="/doctor/login" replace />;
}
function ProtectedPatient({ children }) {
  const { patient } = useAuth();
  return patient ? children : <Navigate to="/patient/login" replace />;
}

export default function App() {
  return (
    <AuthProvider>
      {/* Aurora animated background — Blue · Orange · Green · Red */}
      <div className="bg-canvas">
        <div className="aurora-blob aurora-1" />
        <div className="aurora-blob aurora-2" />
        <div className="aurora-blob aurora-3" />
        <div className="aurora-blob aurora-4" />
      </div>
      <div className="bg-mesh" />

      <ToastContainer />
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<RoleSelection />} />
          <Route path="/doctor/login" element={<DoctorLogin />} />
          <Route path="/doctor/register" element={<RegisterDoctor />} />
          <Route path="/patient/login" element={<PatientLogin />} />
          <Route path="/patient/register" element={<RegisterPatient />} />
          <Route path="/forgot-password" element={<ForgotPassword />} />
          <Route path="/doctor/*" element={<ProtectedDoctor><DoctorDashboard /></ProtectedDoctor>} />
          <Route path="/patient/*" element={<ProtectedPatient><PatientDashboard /></ProtectedPatient>} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
