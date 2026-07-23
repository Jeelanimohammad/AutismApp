import SwiftUI

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case telugu = "te"
    case hindi = "hi"
    case tamil = "ta"
    case kannada = "kn"
    case marathi = "mr"
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .english: return "English"
        case .telugu: return "తెలుగు"
        case .hindi: return "हिन्दी"
        case .tamil: return "தமிழ்"
        case .kannada: return "ಕನ್ನಡ"
        case .marathi: return "मराठी"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var doctorLanguage: Language {
        didSet {
            UserDefaults.standard.set(doctorLanguage.rawValue, forKey: "doctor_selected_language")
        }
    }
    
    @Published var patientLanguage: Language {
        didSet {
            UserDefaults.standard.set(patientLanguage.rawValue, forKey: "patient_selected_language")
        }
    }
    
    private init() {
        if let docSaved = UserDefaults.standard.string(forKey: "doctor_selected_language"),
           let language = Language(rawValue: docSaved) {
            self.doctorLanguage = language
        } else {
            self.doctorLanguage = .english
        }
        
        if let patSaved = UserDefaults.standard.string(forKey: "patient_selected_language"),
           let language = Language(rawValue: patSaved) {
            self.patientLanguage = language
        } else {
            self.patientLanguage = .english
        }
    }
    
    func translateDoctor(_ key: String) -> String {
        return Localization.translate(key, for: doctorLanguage)
    }
    
    func translatePatient(_ key: String) -> String {
        return Localization.translate(key, for: patientLanguage)
    }
}

extension String {
    func localized() -> String {
        // Default to doctor for now, will be overridden by role-specific calls
        return LanguageManager.shared.translateDoctor(self)
    }
    
    func localizedDoctor() -> String {
        return LanguageManager.shared.translateDoctor(self)
    }
    
    func localizedPatient() -> String {
        return LanguageManager.shared.translatePatient(self)
    }
}
