import Foundation

struct DoctorAdvice: Codable, Identifiable {
    var id: String { return created_at ?? UUID().uuidString }
    let advice_text: String
    let doctor_name: String?
    let doctor_id: String?
    let created_at: String?
}
