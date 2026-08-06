import Foundation
import SwiftUI
import SwiftData

class AssessmentViewModel: ObservableObject {
    @Published var symptoms: [Symptom] = []
    @Published var currentSymptomIndex = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isCompleted = false
    @Published var resultMessage: String?
    
    private var responses: [SymptomResponse] = []
    
    var currentSymptom: Symptom? {
        guard currentSymptomIndex < symptoms.count else { return nil }
        return symptoms[currentSymptomIndex]
    }
    
    var progress: Double {
        guard !symptoms.isEmpty else { return 0 }
        return Double(currentSymptomIndex) / Double(symptoms.count)
    }
    
    var yesCount: Int {
        responses.filter { $0.response.lowercased() == "yes" }.count
    }
    
    var totalCount: Int {
        symptoms.count
    }
    
    func fetchSymptoms(ageGroup: String) {
        isLoading = true
        errorMessage = nil
        
        var ageValue = 0
        if ageGroup.contains("<") {
            ageValue = 2
        } else {
            ageValue = 4
        }
        
        let patientID = UserDefaults.standard.string(forKey: "current_patient_id") ?? ""
        
        NetworkManager.shared.getSymptoms(age: ageValue, patientID: patientID) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    self.symptoms = response.data ?? []
                } else {
                    self.errorMessage = response.message
                }
            case .failure(let error):
                self.errorMessage = "Failed to load symptoms: \(error.localizedDescription)"
            }
        }
    }

    func recordResponse(answer: String, context: ModelContext? = nil) {
        guard let symptom = currentSymptom else { return }
        
        let response = SymptomResponse(
            patient_id: 0,
            symptom_name: symptom.symptom_name,
            response: answer,
            conclusion: nil
        )
        responses.append(response)
        
        if currentSymptomIndex < symptoms.count - 1 {
            currentSymptomIndex += 1
        } else {
            submitAllResponses(context: context)
        }
    }
    
    func goBack() {
        if currentSymptomIndex > 0 {
            currentSymptomIndex -= 1
            if !responses.isEmpty {
                responses.removeLast()
            }
        }
    }
    
    func saveOffline(context: ModelContext) {
        let patientID = UserDefaults.standard.string(forKey: "current_patient_id") ?? ""
        let age = UserDefaults.standard.integer(forKey: "current_patient_age")
        
        let offline = OfflineAssessment(patientID: patientID, age: age)
        for resp in responses {
            let offResp = OfflineResponse(
                symptomName: resp.symptom_name,
                answer: resp.response
            )
            offline.responses.append(offResp)
        }
        
        context.insert(offline)
        try? context.save()
        
        self.resultMessage = "Saved offline. Will sync when online."
        self.isCompleted = true
    }

    func submitAllResponses(context: ModelContext? = nil) {
        isLoading = true
        
        let patientID = UserDefaults.standard.string(forKey: "current_patient_id") ?? ""
        let age = UserDefaults.standard.integer(forKey: "current_patient_age")
        
        let encodedResponses = responses.map { response -> [String: AnyEncoded] in
            return [
                "symptom_name": AnyEncoded(response.symptom_name),
                "response": AnyEncoded(response.response),
                "conclusion": AnyEncoded("")
            ]
        }
        
        NetworkManager.shared.submitResponses(patientID: patientID, age: age, responses: encodedResponses) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                if response.success {
                    self.resultMessage = response.result_message
                    self.isCompleted = true
                } else {
                    self.errorMessage = response.message
                }
            case .failure(_):
                if let ctx = context {
                    self.saveOffline(context: ctx)
                } else {
                    self.errorMessage = "Submission failed and no offline context available."
                }
            }
        }
    }
}
