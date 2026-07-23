import Foundation
import SwiftUI

class PatientAdviceViewModel: ObservableObject {
    @Published var adviceList: [DoctorAdvice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedPatientID: String = ""
    @Published var selectedAssessmentID: Int? = nil
    
    func fetchAdvice() {
        guard !selectedPatientID.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        NetworkManager.shared.getAdvice(patientID: selectedPatientID, assessmentID: selectedAssessmentID) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let advice):
                self.adviceList = advice
            case .failure(let error):
                self.errorMessage = "Failed to load advice: \(error.localizedDescription)"
            }
        }
    }
    
    func addAdvice(text: String, doctorName: String, doctorID: String, assessmentID: Int? = nil) {
        guard !selectedPatientID.isEmpty && !text.isEmpty else { return }
        isLoading = true
        
        var parameters: [String: AnyEncoded] = [
            "patient_id": AnyEncoded(selectedPatientID),
            "doctor_name": AnyEncoded(doctorName),
            "doctor_id": AnyEncoded(doctorID),
            "advice_text": AnyEncoded(text)
        ]
        
        if let aid = assessmentID {
            parameters["assessment_id"] = AnyEncoded(aid)
        }
        
        NetworkManager.shared.addDoctorAdvice(advice: parameters) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    self.fetchAdvice() // Refresh
                } else {
                    self.errorMessage = response.message ?? "Failed to save advice"
                }
            case .failure(let error):
                self.errorMessage = "Failed to save advice: \(error.localizedDescription)"
            }
        }
    }
}
