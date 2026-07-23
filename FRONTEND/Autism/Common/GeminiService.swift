import Foundation

class GeminiService {
    static let shared = GeminiService()
    
    // Actual Gemini API Key provided by the user
    private let apiKey = "AIzaSyDEMgXvJSjV3f1LJTdABnEB_FF9uBMOtCs"
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
    
    private init() {}
    
    func generateInsight(responses: [PatientSymptomResponse], completion: @escaping (String) -> Void) {
        let yesSymptoms = responses.filter { $0.response.lowercased() == "yes" }
        let symptomList = yesSymptoms.map { $0.symptom_display_name ?? $0.symptom_name }.joined(separator: ", ")
        
        let prompt = """
        Analyze these symptoms: \(symptomList.isEmpty ? "None" : symptomList). 
        Provide a professional clinical insight for parents.
        STRICT LIMIT: exactly 4 to 5 lines of text. 
        Be concise, empathetic, and professional.
        """
        
        guard let url = URL(string: "\(apiURL)?key=\(apiKey)") else {
            completion("Unable to connect to AI Service.")
            return
        }
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion("Error preparing AI request.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Gemini API Error: \(error.localizedDescription)")
                completion("AI service is temporarily unavailable.")
                return
            }
            
            guard let data = data else {
                completion("No response from AI.")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                if let candidates = json?["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    DispatchQueue.main.async {
                        completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                } else if let error = json?["error"] as? [String: Any],
                          let message = error["message"] as? String {
                    DispatchQueue.main.async {
                        completion("AI Error: \(message)")
                    }
                } else {
                    if let raw = String(data: data, encoding: .utf8) {
                        print("Gemini Raw Response: \(raw)")
                    }
                    completion("AI parsing error. Please check your internet.")
                }
            } catch {
                completion("Technical error in AI processing.")
            }
        }.resume()
    }
}
