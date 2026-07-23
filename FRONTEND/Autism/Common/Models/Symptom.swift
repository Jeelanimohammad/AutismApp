import Foundation

struct Symptom: Codable, Identifiable {
    let id: Int
    let symptom_name: String
    let explanation: String?
    let image_url: String?
    let age_group: String
}

struct SymptomResponse: Codable {
    let patient_id: Int
    let symptom_name: String
    let response: String // "Yes" or "No"
    let conclusion: String?
}

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
}
