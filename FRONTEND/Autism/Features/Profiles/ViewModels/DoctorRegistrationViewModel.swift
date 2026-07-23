import Foundation
import SwiftUI

class DoctorRegistrationViewModel: ObservableObject {
    @Published var name = ""
    @Published var dob = Date()
    @Published var sex = "Male"
    @Published var doctorID = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var navigateToDashboard = false
    
    var age: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: dob, to: Date())
        return components.year ?? 0
    }
    
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
    
    var canRegister: Bool {
        return !isLoading && !email.isEmpty && !name.isEmpty && !doctorID.isEmpty && !phoneNumber.isEmpty && !password.isEmpty
    }
    
    func register() {
        // 1. Name Validation (Letters only)
        let nameRegex = "^[a-zA-Z\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !namePredicate.evaluate(with: name) {
            self.errorMessage = "Name must only contain letters and spaces."
            self.showError = true
            return
        }

        // 2. Phone Validation (10 digits and starts with 6-9)
        let phoneRegex = "^[6-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !phonePredicate.evaluate(with: phoneNumber) {
            self.errorMessage = "Phone number must be 10 digits and start with 6-9."
            self.showError = true
            return
        }

        // 3. Email Validation
        let lowercasedEmail = email.lowercased()
        if !(lowercasedEmail.hasSuffix("@gmail.com") || lowercasedEmail.hasSuffix("@yahoo.com") || lowercasedEmail.hasSuffix("@saveetha.com") || lowercasedEmail.hasSuffix("@outlook.com") || lowercasedEmail.hasSuffix("@hotmail.com")) {
            self.errorMessage = "Email must end with @yahoo.com, @saveetha.com, @outlook.com, @hotmail.com, or @gmail.com"
            self.showError = true
            return
        }

        // 4. Password Validation (At least 4 chars for simplicity or keep strict?)
        // The user previously asked for 'letters, numbers and special characters' for name, 
        // but then 'only letters' later. For password, let's just check length.
        if password.count < 4 {
            self.errorMessage = "Password must be at least 4 characters."
            self.showError = true
            return
        }

        isLoading = true
        let doctorData = [
            "name": name,
            "email": email,
            "doctor_id": doctorID,
            "phone": phoneNumber,
            "password": password,
            "specialization": "Pediatrics" // Default for now
        ]
        
        NetworkManager.shared.registerDoctor(doctor: doctorData) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    // Save session
                    UserDefaults.standard.set(self.doctorID, forKey: "current_doctor_id")
                    UserDefaults.standard.set(self.name, forKey: "current_doctor_name")
                    UserDefaults.standard.set(self.email, forKey: "doctor_email")
                    // Use a delay for smooth transition if needed, or just set it
                    DispatchQueue.main.async {
                        self.navigateToDashboard = true
                    }
                } else {
                    self.errorMessage = response.message ?? "Registration failed"
                    self.showError = true
                }
            case .failure(let error):
                self.errorMessage = "Registration failed: \(error.localizedDescription)"
                self.showError = true
            }
        }
    }
}
