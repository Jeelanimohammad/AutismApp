import Foundation

struct Doctor: Codable, Identifiable {
    let id: Int?
    let doctor_id: String
    let name: String
    let email: String
    let phone: String?
    let specialization: String?
    
    let profile_image: String?
    
    var id_for_swiftui: String {
        return doctor_id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, specialization, profile_image
        case doctor_id = "doctor_id"
    }
}
