import Foundation
import SwiftUI

class PatientsViewModel: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var assessmentHistory: [PatientAssessment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchPatients() {
        isLoading = true
        errorMessage = nil
        
        let doctorID = UserDefaults.standard.string(forKey: "current_doctor_id") ?? ""
        
        NetworkManager.shared.getPatientsList(doctorID: doctorID) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    self.patients = response.patients ?? []
                } else {
                    self.errorMessage = response.message ?? "Failed to fetch patients"
                }
            case .failure(let error):
                self.errorMessage = "Failed to fetch patients: \(error.localizedDescription)"
            }
        }
    }
    
    func generateAIReport(for patient: Patient) -> String {
        guard let responses = patient.responses, !responses.isEmpty else {
            return "No clinical data available yet. Please conduct an initial assessment to generate a health analysis."
        }
        
        let yesResponses = responses.filter { $0.response.lowercased() == "yes" }
        
        if yesResponses.isEmpty {
            return "Based on the latest assessment, the child is currently presenting typical developmental milestones. No immediate autism-related concerns were identified. Continued monitoring of social and communication skills is recommended as age progresses."
        }
        
        // Dynamic analysis based on symptoms
        let symptomNames = yesResponses.map { $0.symptom_display_name ?? $0.symptom_name }.joined(separator: ", ")
        let count = yesResponses.count
        
        var report = "A preliminary analysis of the child's behavior has identified \(count) key concern(s): \(symptomNames).\n\n"
        
        if count >= 3 {
            report += "Clinical observation suggests a high probability of developmental variance. The presence of multiple indicators (including \(yesResponses.first?.symptom_display_name ?? "social markers")) strongly warrants a comprehensive specialist evaluation."
        } else {
            report += "Some mild developmental indicators were noted. While these may be early signs of social-communication challenges, we recommend a focused follow-up in 3 months to monitor progress."
        }
        
        return report
    }

    func fetchAssessmentHistory(patientID: String) {
        isLoading = true
        NetworkManager.shared.getPatientAssessments(patientID: patientID) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .success(let history) = result {
                    self?.assessmentHistory = history
                }
            }
        }
    }

    func deletePatient(patientID: String) {
        // Optimistic UI update: remove immediately with animation
        withAnimation(.spring()) {
            self.patients.removeAll(where: { 
                $0.patient_id.trimmingCharacters(in: .whitespacesAndNewlines) == 
                patientID.trimmingCharacters(in: .whitespacesAndNewlines) 
            })
            self.objectWillChange.send()
        }
        
        NetworkManager.shared.deletePatient(patientID: patientID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if !response.success {
                        // Re-fetch only if server failed
                        self?.fetchPatients()
                        self?.errorMessage = response.message ?? "Server failed to delete"
                    }
                case .failure(let error):
                    // Re-fetch to restore the list on failure
                    self?.fetchPatients()
                    self?.errorMessage = "Deletion failed: \(error.localizedDescription)"
                }
            }
        }
    }
    func removeAssessmentLocally(assessmentID: Int) {
        DispatchQueue.main.async {
            withAnimation {
                self.assessmentHistory.removeAll { $0.id == assessmentID }
            }
        }
    }
}
