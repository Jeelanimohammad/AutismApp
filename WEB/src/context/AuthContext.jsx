import React, { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [doctor, setDoctor] = useState(() => {
    const id = sessionStorage.getItem('doctor_id');
    const name = sessionStorage.getItem('doctor_name');
    return id ? { doctor_id: id, name, email: sessionStorage.getItem('doctor_email'), specialization: sessionStorage.getItem('doctor_specialization') } : null;
  });

  const [patient, setPatient] = useState(() => {
    const id = sessionStorage.getItem('patient_id');
    const name = sessionStorage.getItem('patient_name');
    return id ? { patient_id: id, name } : null;
  });

  const loginDoctor = (data) => {
    sessionStorage.setItem('doctor_id', data.doctor_id);
    sessionStorage.setItem('doctor_name', data.name);
    sessionStorage.setItem('doctor_email', data.email || '');
    sessionStorage.setItem('doctor_specialization', data.specialization || '');
    setDoctor(data);
  };

  const loginPatient = (data) => {
    sessionStorage.setItem('patient_id', data.patient_id);
    sessionStorage.setItem('patient_name', data.name);
    setPatient(data);
  };

  const logoutDoctor = () => {
    ['doctor_id', 'doctor_name', 'doctor_email', 'doctor_specialization'].forEach(k => sessionStorage.removeItem(k));
    setDoctor(null);
  };

  const logoutPatient = () => {
    ['patient_id', 'patient_name'].forEach(k => sessionStorage.removeItem(k));
    setPatient(null);
  };

  return (
    <AuthContext.Provider value={{ doctor, patient, loginDoctor, loginPatient, logoutDoctor, logoutPatient }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
