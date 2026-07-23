import { Routes, Route, Navigate } from 'react-router-dom';
import DoctorSidebar from '../../components/DoctorSidebar';

import PatientsList from './PatientsList';
import PatientDetails from './PatientDetails';
import DoctorProfile from './DoctorProfile';
import DoctorAnalytics from './DoctorAnalytics';
import DoctorHome from './DoctorHome';

export default function DoctorDashboard() {
  return (
    <div className="sidebar-layout">
      <DoctorSidebar />
      <div className="main-content">
        <Routes>
          <Route path="home" element={<DoctorHome />} />
          <Route path="patients" element={<PatientsList />} />
          <Route path="patients/:patientId" element={<PatientDetails />} />
          <Route path="profile" element={<DoctorProfile />} />
          <Route path="analytics" element={<DoctorAnalytics />} />
          <Route path="*" element={<Navigate to="patients" replace />} />
        </Routes>
      </div>
    </div>
  );
}
