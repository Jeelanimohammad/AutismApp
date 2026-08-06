import Foundation
import SwiftUI

class PatientRegistrationViewModel: ObservableObject {
    @Published var name = ""
    @Published var dob = Date()
    @Published var sex = "Male"
    @Published var patientID = ""
    @Published var phoneNumber = ""
    @Published var email = ""
    @Published var password = ""
    @Published var profileImageBase64: String? = nil
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var navigateToDashboard = false
    
    var age: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: dob, to: Date())
        return components.year ?? 0
    }
    
    // Password must be at least 4 characters (matches web app and backend)
    var isPasswordValid: Bool { password.count >= 4 }
    
    var isNameValid: Bool {
        let nameRegex = "^[a-zA-Z\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: name)
    }
    
    var isPhoneValid: Bool {
        let phoneRegex = "^[6-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    var canRegister: Bool {
        return !isLoading && !name.isEmpty && !patientID.isEmpty && !password.isEmpty
    }
    
    func register() {
        if !isNameValid {
            errorMessage = "Name must only contain letters and spaces."
            showError = true
            return
        }
        
        if !phoneNumber.isEmpty && !isPhoneValid {
            errorMessage = "Phone number must be 10 digits and start with 6-9."
            showError = true
            return
        }

        let lowercasedEmail = email.lowercased()
        if !(lowercasedEmail.hasSuffix("@gmail.com") || lowercasedEmail.hasSuffix("@yahoo.com") || lowercasedEmail.hasSuffix("@saveetha.com") || lowercasedEmail.hasSuffix("@outlook.com") || lowercasedEmail.hasSuffix("@hotmail.com")) {
            errorMessage = "Please enter a valid email address (ending with @yahoo.com, @saveetha.com, @outlook.com, @hotmail.com, or @gmail.com)."
            showError = true
            return
        }

        if !isPasswordValid {
            errorMessage = "Password must be at least 4 characters."
            showError = true
            return
        }


        isLoading = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dobString = formatter.string(from: dob)
        
        let parameters = [
            "name": name,
            "patient_id": patientID,
            "age": "\(age)",
            "dob": dobString,
            "sex": sex,
            "phone": phoneNumber,
            "email": email,
            "password": password,
            "profile_image": profileImageBase64 ?? ""
        ]
        
        NetworkManager.shared.registerPatient(patient: parameters) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    // Save session data
                    UserDefaults.standard.set(self.patientID, forKey: "current_patient_id")
                    UserDefaults.standard.set(self.name, forKey: "current_patient_name")
                    UserDefaults.standard.set(self.age, forKey: "current_patient_age")
                    self.navigateToDashboard = true
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
