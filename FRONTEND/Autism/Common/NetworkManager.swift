import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    // Change this to your server IP for testing on real device
    let baseURL = "http://172.25.85.139/autism"
    
    private init() {}
    
    // Generic request method for JSON (POST)
    private func sendRequest<Request: Encodable, Response: Decodable>(
        endpoint: String,
        parameters: Request,
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) {
        let urlString = "\(baseURL)/\(endpoint)"
        let cacheBustedString = urlString.contains("?") ? "\(urlString)&cb=\(Date().timeIntervalSince1970)" : "\(urlString)?cb=\(Date().timeIntervalSince1970)"
        
        guard let url = URL(string: cacheBustedString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Pass patient_id in header as a 3rd fallback
        if let params = parameters as? [String: String], let pid = params["patient_id"] {
            request.setValue(pid, forHTTPHeaderField: "X-Patient-ID")
        }
        if let params = parameters as? [String: AnyEncoded], let pid = params["assessment_id"] {
            // For assessments
            request.setValue("\(pid)", forHTTPHeaderField: "X-Assessment-ID")
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            completion(.failure(.encodingFailed))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.connectionError(error))) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.failure(.serverError("Status code: \(httpResponse.statusCode)"))) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                let rawResponse = String(data: data, encoding: .utf8) ?? "Empty response"
                print("Decoding error. Server response: \(rawResponse)")
                // Show the raw response in the error message for debugging
                DispatchQueue.main.async { 
                    completion(.failure(.serverError("Format error. Server said: \(rawResponse.prefix(100))..."))) 
                }
            }
        }.resume()
    }
    
    // Generic request for GET requests (or simple POST without body parameters)
    private func fetch<Response: Decodable>(
        endpoint: String,
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.connectionError(error))) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(.failure(.serverError("Status code: \(httpResponse.statusCode)"))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
                DispatchQueue.main.async { completion(.success(decodedResponse)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingFailed)) }
            }
        }.resume()
    }
}

// MARK: - Enums & Model Wrappers for API
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed
    case connectionError(Error)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid server URL"
        case .encodingFailed: return "Failed to process request data"
        case .noData: return "No response from server"
        case .decodingFailed: return "Server returned invalid data format"
        case .connectionError(let error): return "Connection error: \(error.localizedDescription)"
        case .serverError(let message): return "Server error: \(message)"
        }
    }
}

struct BasicResponse: Codable {
    let success: Bool
    let message: String?
    let result_message: String? // Added this to capture the autism assessment result
}

struct DoctorLoginResponse: Codable {
    let success: Bool
    let message: String?
    let doctor: Doctor?
}

struct PatientLoginResponse: Codable {
    let success: Bool
    let message: String?
    let name: String?
    let patient_id: String?
    let patient_db_id: Int?
    let age: Int?
    let profile_image: String?

    enum CodingKeys: String, CodingKey {
        case success, message, name, patient_id, patient_db_id, age, profile_image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        patient_id = try container.decodeIfPresent(String.self, forKey: .patient_id)
        profile_image = try container.decodeIfPresent(String.self, forKey: .profile_image)
        
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
    }
}

struct PatientAssessment: Codable, Identifiable {
    let id: Int
    let result_message: String
    let created_at: String
    let has_feedback: Int? // 1 if exists, 0 if not
}

struct AssessmentDetailsResponse: Codable {
    let success: Bool
    let result_message: String
    let created_at: String
    let responses: [PatientSymptomResponse]
}

struct PatientsListResponse: Codable {
    let success: Bool
    let message: String?
    let patients: [Patient]?
}

struct PatientProfile: Codable {
    let id: Int?
    let patient_id: String
    let name: String
    let age: Int?
    let dob: String
    let sex: String
    let phone: String
    let email: String
    let profile_image: String?
    let created_at: String

    enum CodingKeys: String, CodingKey {
        case id, patient_id, name, age, dob, sex, phone, email, profile_image, created_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        patient_id = try container.decode(String.self, forKey: .patient_id)
        name = try container.decode(String.self, forKey: .name)
        dob = try container.decode(String.self, forKey: .dob)
        sex = try container.decode(String.self, forKey: .sex)
        phone = try container.decode(String.self, forKey: .phone)
        email = try container.decode(String.self, forKey: .email)
        profile_image = try container.decodeIfPresent(String.self, forKey: .profile_image)
        created_at = try container.decode(String.self, forKey: .created_at)
        
        // Handle numeric fields that might be strings
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = idInt
        } else if let idStr = try? container.decode(String.self, forKey: .id), let val = Int(idStr) {
            id = val
        } else {
            id = nil
        }
        
        if let ageInt = try? container.decode(Int.self, forKey: .age) {
            age = ageInt
        } else if let ageStr = try? container.decode(String.self, forKey: .age), let val = Int(ageStr) {
            age = val
        } else {
            age = nil
        }
    }
}

struct PatientProfileResponse: Codable {
    let success: Bool
    let message: String?
    let data: PatientProfile?
}

struct SymptomsResponse: Codable {
    let success: Bool
    let message: String?
    let data: [Symptom]?
}

struct Message: Codable, Identifiable {
    let id: Int
    let sender_id: String
    let receiver_id: String
    let sender_role: String
    let message_text: String
    let created_at: String
    let is_read: Int

    enum CodingKeys: String, CodingKey {
        case id, sender_id, receiver_id, sender_role, message_text, created_at, is_read
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sender_id = try container.decode(String.self, forKey: .sender_id)
        receiver_id = try container.decode(String.self, forKey: .receiver_id)
        sender_role = try container.decode(String.self, forKey: .sender_role)
        message_text = try container.decode(String.self, forKey: .message_text)
        created_at = try container.decode(String.self, forKey: .created_at)

        // Robust decoding for 'id'
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            id = idInt
        } else if let idStr = try? container.decode(String.self, forKey: .id), let val = Int(idStr) {
            id = val
        } else {
            id = 0
        }

        // Robust decoding for 'is_read'
        if let readInt = try? container.decode(Int.self, forKey: .is_read) {
            is_read = readInt
        } else if let readStr = try? container.decode(String.self, forKey: .is_read), let val = Int(readStr) {
            is_read = val
        } else {
            is_read = 0
        }
    }
}

struct MessagesResponse: Codable {
    let success: Bool
    let messages: [Message]?
    let message: String?
    let is_online: Bool?
}

// MARK: - API Methods
extension NetworkManager {
    
    func sendMessage(parameters: [String: AnyEncoded], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "send_message.php", parameters: parameters, completion: completion)
    }
    
    func getMessages(user1: String, user2: String, role: String, completion: @escaping (Result<MessagesResponse, NetworkError>) -> Void) {
        fetch(endpoint: "get_messages.php?user1=\(user1)&user2=\(user2)&role=\(role)", completion: completion)
    }
    
    func loginDoctor(credentials: [String: String], completion: @escaping (Result<DoctorLoginResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "doctorlogin.php", parameters: credentials, completion: completion)
    }
    
    func registerDoctor(doctor: [String: String], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "doctorregister.php", parameters: doctor, completion: completion)
    }
    
    func loginPatient(credentials: [String: String], completion: @escaping (Result<PatientLoginResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "parentlogin.php", parameters: credentials, completion: completion)
    }
    
    func registerPatient(patient: [String: String], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "patientdetails.php", parameters: patient, completion: completion)
    }
    
    func addDoctorAdvice(advice: [String: AnyEncoded], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "add_advice.php", parameters: advice, completion: completion)
    }
    
    func getPatientsList(doctorID: String, completion: @escaping (Result<PatientsListResponse, NetworkError>) -> Void) {
        fetch(endpoint: "get_patients_with_symptoms.php?doctor_id=\(doctorID)", completion: completion)
    }
    
    func getSymptoms(age: Int, patientID: String, completion: @escaping (Result<SymptomsResponse, NetworkError>) -> Void) {
        // The PHP script get_symptoms_by_age.php expects "age" and optionally "patient_id"
        let parameters: [String: AnyEncoded] = [
            "age": AnyEncoded(age),
            "patient_id": AnyEncoded(patientID)
        ]
        sendRequest(endpoint: "get_symptoms_by_age.php", parameters: parameters, completion: completion)
    }
    
    func submitResponses(patientID: String, age: Int, responses: [[String: AnyEncoded]], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        let parameters: [String: AnyEncoded] = [
            "patient_id": AnyEncoded(patientID),
            "age": AnyEncoded(age),
            "responses": AnyEncoded(responses)
        ]
        sendRequest(endpoint: "submit_symptom_responses.php", parameters: parameters, completion: completion)
    }
    
    func getAdvice(patientID: String, assessmentID: Int? = nil, completion: @escaping (Result<[DoctorAdvice], NetworkError>) -> Void) {
        var endpoint = "get_advice.php?patient_id=\(patientID)"
        if let aid = assessmentID {
            endpoint += "&assessment_id=\(aid)"
        }
        fetch(endpoint: endpoint, completion: completion)
    }
    
    
    func getPatientProfile(patientID: String, completion: @escaping (Result<PatientProfileResponse, NetworkError>) -> Void) {
        fetch(endpoint: "get_patient_profile.php?patient_id=\(patientID)", completion: completion)
    }
    
    func getPatientReports(patientID: String, completion: @escaping (Result<[DoctorAdvice], NetworkError>) -> Void) {
        fetch(endpoint: "get_advice.php?patient_id=\(patientID)", completion: completion)
    }

    func getPatientAssessments(patientID: String, completion: @escaping (Result<[PatientAssessment], NetworkError>) -> Void) {
        fetch(endpoint: "get_assessments.php?patient_id=\(patientID)", completion: completion)
    }

    func getDoctorProfile(doctorID: String, completion: @escaping (Result<DoctorLoginResponse, NetworkError>) -> Void) {
        fetch(endpoint: "get_doctor_profile.php?doctor_id=\(doctorID)", completion: completion)
    }

    func getAssessmentDetails(assessmentID: Int, completion: @escaping (Result<AssessmentDetailsResponse, NetworkError>) -> Void) {
        fetch(endpoint: "get_assessment_details.php?assessment_id=\(assessmentID)", completion: completion)
    }

    func deletePatient(patientID: String, completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        // Putting the ID in the URL is more robust for some PHP server configurations
        let parameters = ["patient_id": patientID]
        let endpointWithID = "delete_patient.php?patient_id=\(patientID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? patientID)"
        sendRequest(endpoint: endpointWithID, parameters: parameters, completion: completion)
    }

    func updatePatientProfile(parameters: [String: AnyEncoded], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "update_patient_profile.php", parameters: parameters, completion: completion)
    }

    func updateDoctorProfile(parameters: [String: AnyEncoded], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "update_doctor_profile.php", parameters: parameters, completion: completion)
    }

    func resetPassword(parameters: [String: String], completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        sendRequest(endpoint: "reset_password.php", parameters: parameters, completion: completion)
    }
    func deleteAssessment(assessmentID: Int, completion: @escaping (Result<BasicResponse, NetworkError>) -> Void) {
        let parameters: [String: AnyEncoded] = ["assessment_id": AnyEncoded(assessmentID)]
        let endpointWithID = "delete_assessment.php?assessment_id=\(assessmentID)"
        sendRequest(endpoint: endpointWithID, parameters: parameters, completion: completion)
    }
}

// Helper for dynamic dictionaries in JSON encoding
struct AnyEncoded: Encodable {
    private let encode: (Encoder) throws -> Void
    init<T: Encodable>(_ wrapped: T) {
        encode = wrapped.encode
    }
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
