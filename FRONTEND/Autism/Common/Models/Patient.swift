import Foundation

struct Patient: Codable, Identifiable {
    var id: String { return patient_id }
    let patient_db_id: Int?
    let patient_id: String
    let name: String
    let age: Int?
    let dob: String?
    let sex: String?
    let phone: String?
    let profile_image: String?
    let created_at: String?
    let pending_reviews: Int?
    let reviewed_count: Int?
    let has_advice: Int?
    let responses: [PatientSymptomResponse]?
    
    enum CodingKeys: String, CodingKey {
        case patient_db_id = "id"
        case patient_id, name, age, dob, sex, phone, profile_image, created_at, pending_reviews, reviewed_count, has_advice, responses
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        patient_id = try container.decode(String.self, forKey: .patient_id).trimmingCharacters(in: .whitespacesAndNewlines)
        name = try container.decode(String.self, forKey: .name)
        dob = try container.decodeIfPresent(String.self, forKey: .dob)
        sex = try container.decodeIfPresent(String.self, forKey: .sex)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        profile_image = try container.decodeIfPresent(String.self, forKey: .profile_image)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        
        // Handle numeric fields that might be strings from PHP
        if let ageInt = try? container.decodeIfPresent(Int.self, forKey: .age) {
            age = ageInt
        } else if let ageStr = try? container.decodeIfPresent(String.self, forKey: .age) {
            age = Int(ageStr)
        } else {
            age = nil
        }
        
        if let dbIdInt = try? container.decodeIfPresent(Int.self, forKey: .patient_db_id) {
            patient_db_id = dbIdInt
        } else if let dbIdStr = try? container.decodeIfPresent(String.self, forKey: .patient_db_id) {
            patient_db_id = Int(dbIdStr)
        } else {
            patient_db_id = nil
        }

        if let pendingInt = try? container.decodeIfPresent(Int.self, forKey: .pending_reviews) {
            pending_reviews = pendingInt
        } else if let pendingStr = try? container.decodeIfPresent(String.self, forKey: .pending_reviews) {
            pending_reviews = Int(pendingStr)
        } else {
            pending_reviews = nil
        }

        if let revInt = try? container.decodeIfPresent(Int.self, forKey: .reviewed_count) {
            reviewed_count = revInt
        } else if let revStr = try? container.decodeIfPresent(String.self, forKey: .reviewed_count) {
            reviewed_count = Int(revStr)
        } else {
            reviewed_count = nil
        }

        if let adviceInt = try? container.decodeIfPresent(Int.self, forKey: .has_advice) {
            has_advice = adviceInt
        } else if let adviceStr = try? container.decodeIfPresent(String.self, forKey: .has_advice) {
            has_advice = Int(adviceStr)
        } else {
            has_advice = nil
        }

        responses = try container.decodeIfPresent([PatientSymptomResponse].self, forKey: .responses)
    }
}

struct PatientSymptomResponse: Codable {
    let symptom_name: String
    let symptom_display_name: String?
    let response: String
    let conclusion: String?
}
