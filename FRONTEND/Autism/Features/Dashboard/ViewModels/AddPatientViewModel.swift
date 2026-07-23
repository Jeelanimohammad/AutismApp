import Foundation
import SwiftUI

class AddPatientViewModel: ObservableObject {
    @Published var name = ""
    @Published var patientID = ""
    @Published var age = ""
    @Published var dob = Date()
    @Published var sex = "Male"
    @Published var phone = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var success = false
    
    func addPatient(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateFormatter.string(from: dob)
        
        let doctorID = UserDefaults.standard.string(forKey: "current_doctor_id") ?? ""
        
        let parameters = [
            "name": name,
            "patient_id": patientID,
            "age": age,
            "dob": dobString,
            "sex": sex,
            "phone": phone,
            "password": password,
            "doctor_id": doctorID
        ]
        
        NetworkManager.shared.registerPatient(patient: parameters) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    self.success = true
                    completion(true)
                } else {
                    self.errorMessage = response.message
                    completion(false)
                }
            case .failure(let error):
                self.errorMessage = "Failed to add patient: \(error.localizedDescription)"
                completion(false)
            }
        }
    }
}
