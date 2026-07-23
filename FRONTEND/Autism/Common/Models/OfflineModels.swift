import Foundation
import SwiftData

@Model
class OfflineAssessment {
    var id: String // UUID or timestamp
    var patientID: String
    var age: Int
    var timestamp: Date
    var isSynced: Bool
    
    @Relationship(deleteRule: .cascade) var responses: [OfflineResponse] = []
    
    init(patientID: String, age: Int) {
        self.id = UUID().uuidString
        self.patientID = patientID
        self.age = age
        self.timestamp = Date()
        self.isSynced = false
    }
}

@Model
class OfflineResponse {
    var symptomName: String
    var answer: String
    
    init(symptomName: String, answer: String) {
        self.symptomName = symptomName
        self.answer = answer
    }
}
