import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import PatientSidebar from '../../components/PatientSidebar';
import AssessmentList from './AssessmentList';
import NewAssessment from './NewAssessment';
import PatientProfile from './PatientProfile';
import PatientHome from './PatientHome';

export default function PatientDashboard() {
  const location = useLocation();
  return (
    <div className="sidebar-layout">
      <PatientSidebar />
      <div className="main-content">
        <Routes>
          <Route path="home" element={<PatientHome key={location.key} />} />
          <Route path="assessments" element={<AssessmentList />} />
          <Route path="assess" element={<NewAssessment />} />
          <Route path="profile" element={<PatientProfile />} />
          <Route path="*" element={<Navigate to="home" replace />} />
        </Routes>
      </div>
    </div>
  );
}
