import Foundation
import SwiftUI

class DoctorLoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var navigateToDashboard = false
    
    @Published var passwordMessage = ""
    @Published var passwordColor = Color.red
    
    func validatePassword() {
        if password.isEmpty {
            passwordMessage = ""
        } else if password.count < 4 {
            passwordMessage = "Password must be at least 4 characters"
            passwordColor = .red
        } else {
            passwordMessage = ""
            passwordColor = .green
        }
    }
    
    // Login only needs non-empty credentials — server handles authentication
    var isLoginEnabled: Bool {
        return !email.isEmpty && !password.isEmpty && !isLoading
    }
    
    func login() {
        isLoading = true
        let credentials = ["email": email, "password": password]
        
        NetworkManager.shared.loginDoctor(credentials: credentials) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    // Save doctor session
                    UserDefaults.standard.set(response.doctor?.doctor_id, forKey: "current_doctor_id")
                    UserDefaults.standard.set(response.doctor?.name, forKey: "current_doctor_name")
                    UserDefaults.standard.set(response.doctor?.email, forKey: "doctor_email")
                    UserDefaults.standard.set(response.doctor?.specialization, forKey: "doctor_specialization")
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
