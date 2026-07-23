import Foundation
import SwiftUI

class PatientLoginViewModel: ObservableObject {
    @Published var patientID = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var navigateToDashboard = false
    
    var passwordValidation: [String] {
        var messages: [String] = []
        if password.count < 8 { messages.append("• Minimum 8 characters") }
        if password.range(of: "[A-Z]", options: .regularExpression) == nil { messages.append("• At least 1 uppercase letter") }
        if password.range(of: "[a-z]", options: .regularExpression) == nil { messages.append("• At least 1 lowercase letter") }
        if password.range(of: "[0-9]", options: .regularExpression) == nil { messages.append("• At least 1 number") }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) == nil { messages.append("• At least 1 special character") }
        return messages
    }
    
    var isPasswordValid: Bool { passwordValidation.isEmpty }

    var isLoginEnabled: Bool {
        return !patientID.isEmpty && isPasswordValid && !isLoading
    }
    
    func login() {
        isLoading = true
        let credentials = ["patient_id": patientID, "password": password]
        
        NetworkManager.shared.loginPatient(credentials: credentials) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    // Save patient session
                    UserDefaults.standard.set(response.patient_id, forKey: "current_patient_id")
                    UserDefaults.standard.set(response.patient_db_id, forKey: "current_patient_db_id")
                    UserDefaults.standard.set(response.name, forKey: "current_patient_name")
                    UserDefaults.standard.set(response.age, forKey: "current_patient_age")
                    UserDefaults.standard.set(response.profile_image, forKey: "current_patient_image")
                    self.navigateToDashboard = true
                } else {
                    self.errorMessage = response.message ?? "Invalid login"
                    self.showError = true
                }
            case .failure(let error):
                self.errorMessage = self.mapError(error)
                self.showError = true
            }
        }
    }
    
    private func mapError(_ error: NetworkError) -> String {
        switch error {
        case .invalidURL: return "Invalid server URL"
        case .encodingFailed: return "Failed to process request data"
        case .noData: return "No response from server"
        case .decodingFailed: return "Server returned invalid data"
        case .connectionError(let err): return "Connection failed: \(err.localizedDescription)"
        case .serverError(let msg): return msg
        }
    }
}
