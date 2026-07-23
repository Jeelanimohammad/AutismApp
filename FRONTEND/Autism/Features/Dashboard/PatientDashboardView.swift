import SwiftUI
import PhotosUI

struct PatientDashboardView: View {
    @Binding var isPresented: Bool
    @State private var selectedTab = 0
    let patientID: String
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var adviceViewModel = PatientAdviceViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                PatientHomeOverview(isPresented: $isPresented, patientID: patientID)
            }
            .environmentObject(LanguageManager.shared)
            .tabItem {
                Label("home".localizedPatient(), systemImage: "house.fill")
            }
            .tag(0)
            
            // Reports Tab
            NavigationStack {
                PatientReportsView(patientID: patientID)
            }
            .environmentObject(LanguageManager.shared)
            .tabItem {
                Label("reports".localizedPatient(), systemImage: "doc.text.fill")
            }
            .tag(1)
            
            // Profile Tab
            NavigationStack {
                PatientProfileView(isPresented: $isPresented, patientID: patientID)
            }
            .environmentObject(LanguageManager.shared)
            .tabItem {
                Label("profile".localizedPatient(), systemImage: "person.fill")
            }
            .tag(2)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            adviceViewModel.selectedPatientID = patientID
            adviceViewModel.fetchAdvice()
        }
    }
}

struct TrendItem: Identifiable {
    let id = UUID()
    let month: String
    let fullKey: String
    let isSevere: Bool
    let score: CGFloat
    let hasData: Bool
    let count: Int
}

// MARK: - Trends View
struct PatientTrendsSection: View {
    let history: [PatientAssessment]
    @Binding var selectedMonth: String?
    
    var trends: [TrendItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM yyyy"
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM"
        
        var historyDict: [String: PatientAssessment] = [:]
        var historyCountDict: [String: Int] = [:]
        for assessment in history {
            if let date = formatter.date(from: assessment.created_at) {
                let key = monthFormatter.string(from: date)
                let msg = assessment.result_message.lowercased()
                let isSevere = msg.contains("further") || msg.contains("concern") || msg.contains("attention")
                
                historyCountDict[key, default: 0] += 1
                
                if let existing = historyDict[key] {
                     let exMsg = existing.result_message.lowercased()
                     let exSevere = exMsg.contains("further") || exMsg.contains("concern") || exMsg.contains("attention")
                     if isSevere && !exSevere {
                         historyDict[key] = assessment // prioritize severe
                     }
                } else {
                     historyDict[key] = assessment
                }
            }
        }
        
        var items: [TrendItem] = []
        let calendar = Calendar.current
        let currentDate = Date()
        
        for i in (0..<12).reversed() { // Last 12 months
            if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                let key = monthFormatter.string(from: date)
                let displayMonth = displayFormatter.string(from: date)
                
                if let assessment = historyDict[key] {
                    let msg = assessment.result_message.lowercased()
                    let isSevere = msg.contains("further") || msg.contains("concern") || msg.contains("attention")
                    items.append(TrendItem(month: displayMonth, fullKey: key, isSevere: isSevere, score: isSevere ? 0.35 : 0.85, hasData: true, count: historyCountDict[key] ?? 1))
                } else {
                    items.append(TrendItem(month: displayMonth, fullKey: key, isSevere: false, score: 0.1, hasData: false, count: 0))
                }
            }
        }
        return items
    }
    
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("monthly_timeline".localizedPatient())
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
            
            if trends.isEmpty {
                 Text("No historical data available to plot trends.")
                     .font(.subheadline)
                     .foregroundColor(.gray)
            } else {
                VStack(spacing: 10) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 20) {
                            ForEach(trends) { trend in
                                VStack(spacing: 8) {
                                    // Count Badge
                                    if trend.hasData {
                                        Text("\(trend.count)")
                                            .font(.system(size: 10, weight: .black, design: .rounded))
                                            .foregroundColor(Color(hex: "3B82F6"))
                                            .frame(width: 22, height: 22)
                                            .background(Color(hex: "3B82F6").opacity(0.15))
                                            .clipShape(Circle())
                                    } else {
                                        Spacer().frame(height: 22)
                                    }
                                    
                                    // Bar
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            !trend.hasData ? LinearGradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.25)], startPoint: .bottom, endPoint: .top) :
                                            LinearGradient(colors: [Color(hex: "3B82F6"), Color.cyan], startPoint: .bottom, endPoint: .top)
                                        )
                                        .frame(width: 35, height: trend.hasData ? 80 : 20)
                                        .opacity(selectedMonth == nil || selectedMonth == trend.fullKey ? 1.0 : 0.4)
                                        
                                    // Month Label
                                    Text(trend.month)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(selectedMonth == trend.fullKey ? Color(hex: "3B82F6") : Color.gray)
                                }
                                .frame(width: 40)
                                .onTapGesture {
                                    if trend.hasData {
                                        withAnimation(.spring()) {
                                            selectedMonth = (selectedMonth == trend.fullKey) ? nil : trend.fullKey
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 125, alignment: .bottom)
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Reports View
struct PatientReportsView: View {
    let patientID: String
    @StateObject private var viewModel = PatientsViewModel()
    @State private var selectedMonth: String? = nil
    @EnvironmentObject var languageManager: LanguageManager
    
    var filteredHistory: [PatientAssessment] {
        guard let selected = selectedMonth else { return viewModel.assessmentHistory }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM yyyy"
        
        return viewModel.assessmentHistory.filter { assessment in
            if let date = formatter.date(from: assessment.created_at) {
                return monthFormatter.string(from: date) == selected
            }
            return false
        }
    }
    
    var body: some View {
        StandardBackground {
            
            // ── Floating ambient orbs ──────────────────────────────────────
            ScrollView {
                VStack(spacing: 20) {
                    
                    if !viewModel.assessmentHistory.isEmpty {
                        PatientTrendsSection(history: viewModel.assessmentHistory, selectedMonth: $selectedMonth)
                            .padding(.bottom, 10)
                    }
                    
                    if filteredHistory.isEmpty && !viewModel.assessmentHistory.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(Color.gray.opacity(0.5))
                            Text("no_reports_month".localizedPatient())
                                .foregroundColor(Color.gray)
                        }
                        .padding(.top, 40)
                    } else if viewModel.assessmentHistory.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(Color.gray.opacity(0.5))
                            Text("no_reports_yet".localizedPatient())
                                .foregroundColor(Color.gray)
                                .italic()
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(filteredHistory) { assessment in
                            NavigationLink {
                                AssessmentDetailView(assessmentId: assessment.id, patientID: patientID, patientName: UserDefaults.standard.string(forKey: "current_patient_name") ?? "", isDoctor: false) {
                                    viewModel.removeAssessmentLocally(assessmentID: assessment.id)
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(assessment.result_message.localizedPatient())
                                                .font(.headline)
                                                .foregroundColor(Color.black.opacity(0.85))
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            if assessment.has_feedback == 1 {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .foregroundColor(.green)
                                                    .font(.title3)
                                            }
                                        }
                                        
                                        HStack {
                                            Image(systemName: "calendar")
                                                .foregroundColor(.cyan)
                                            Text(assessment.created_at)
                                                .font(.caption)
                                                .foregroundColor(Color.gray)
                                        }
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.gray.opacity(0.6))
                                        .padding(.leading, 10)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("your_reports".localizedPatient())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchAssessmentHistory(patientID: patientID)
            }
        }
    }
}

// MARK: - Profile View
struct PatientProfileView: View {
    @Binding var isPresented: Bool
    let patientID: String
    @EnvironmentObject var languageManager: LanguageManager
    @State private var profile: PatientProfile?
    @State private var isLoading = true
    @State private var isEditing = false
    
    // Photo Selection
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isUploading = false
    
    var body: some View {
        StandardBackground {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .tint(Color.blue)
                    } else if let profile = profile {
                        // Profile Header with Photo Picker
                        VStack(spacing: 20) {
                            ZStack {
                                // Camera ring animation
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.cyan.opacity(0.6), .clear, .blue.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 136, height: 136)
                                
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    ZStack {
                                        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                        } else if let imagePath = profile.profile_image, !imagePath.isEmpty {
                                            let host = URL(string: NetworkManager.shared.baseURL)?.host ?? ""
                                            let finalPath = imagePath.replacingOccurrences(of: "localhost", with: host)
                                            let fullUrl = finalPath.lowercased().hasPrefix("http") ? finalPath : "\(NetworkManager.shared.baseURL)/\(finalPath)"
                                            
                                            VStack(spacing: 4) {
                                                AsyncImage(url: URL(string: fullUrl)) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image.resizable()
                                                            .scaledToFill()
                                                            .frame(width: 120, height: 120)
                                                            .clipShape(Circle())
                                                    case .failure(_):
                                                        Circle()
                                                            .fill(Color.white)
                                                            .frame(width: 120, height: 120)
                                                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                                                            .overlay(
                                                                VStack(spacing: 4) {
                                                                    Image(systemName: "exclamationmark.circle.fill")
                                                                        .font(.system(size: 30))
                                                                    Text("FAIL")
                                                                        .font(.system(size: 8))
                                                                }
                                                                .foregroundColor(.red)
                                                            )
                                                    case .empty:
                                                        ProgressView().tint(Color.blue)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                        } else {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 120, height: 120)
                                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                                                .overlay(
                                                    VStack(spacing: 4) {
                                                        Image(systemName: "camera.shutter.button.fill")
                                                            .font(.system(size: 32))
                                                         Text("add_photo".localizedPatient())
                                                            .font(.system(size: 10, weight: .bold))
                                                    }
                                                    .foregroundColor(.cyan)
                                                )
                                        }
                                        
                                        if isUploading {
                                            ZStack {
                                                Circle().fill(Color.white.opacity(0.5)).frame(width: 120, height: 120)
                                                ProgressView().tint(Color.blue)
                                            }
                                        }
                                    }
                                    .shadow(color: .cyan.opacity(0.3), radius: 15)
                                }
                                .onChange(of: selectedItem) { old, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            selectedImageData = data
                                            uploadPhoto(data: data)
                                        }
                                    }
                                }
                            }
                            
                            Text(profile.name)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black.opacity(0.85))
                            
                             Text("\("patient_id_label".localizedPatient()): \(profile.patient_id)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.25))
                                .cornerRadius(20)
                        }
                        .padding(.top, 40)
                        .padding(.vertical)
                        
                        // Detail Cards
                        VStack(spacing: 12) {
                            profileRow(icon: "calendar", title: "date_of_birth".localizedPatient(), value: profile.dob)
                            profileRow(icon: "person.fill", title: "age_label".localizedPatient(), value: "\(profile.age ?? 0) \("years".localizedPatient())")
                            profileRow(icon: "person.and.arrow.left.and.right", title: "gender".localizedPatient(), value: profile.sex)
                            profileRow(icon: "phone.fill", title: "phone_number".localizedPatient(), value: profile.phone)
                            profileRow(icon: "envelope.fill", title: "email_address".localizedPatient(), value: profile.email)
                            profileRow(icon: "clock.fill", title: "registered_on".localizedPatient(), value: profile.created_at)
                        }
                        .padding(.horizontal)
                        
                        // Language Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("language_settings".localizedPatient())
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3))
                                .padding(.horizontal, 4)
                            
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(Color(hex: "3B82F6"))
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 30)
                                
                                Text("select_language".localizedPatient())
                                    .font(.body)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Picker("", selection: $languageManager.patientLanguage) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.name).tag(lang)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color(hex: "3B82F6"))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        


                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "current_patient_id")
                            UserDefaults.standard.removeObject(forKey: "current_patient_name")
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController = UIHostingController(rootView: NavigationStack {
                                    RoleSelectionView()
                                }.environmentObject(LanguageManager.shared))
                                window.makeKeyAndVisible()
                            }
                        }) {
                            Text("sign_out".localizedPatient())
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [Color.pink, Color.red], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(20)
                                .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                        .padding(.top, 10)
                    }
                }
            }
        }
        .navigationTitle("your_profile".localizedPatient())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if profile != nil {
                    Button("edit".localizedPatient()) {
                        isEditing = true
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            if let profile = profile {
                EditPatientProfileView(profile: profile) {
                    fetchProfile()
                }
            }
        }
        .onAppear {
            fetchProfile()
        }
    }
    
    func fetchProfile() {
        NetworkManager.shared.getPatientProfile(patientID: patientID) { result in
            isLoading = false
            if case .success(let response) = result {
                self.profile = response.data
            }
        }
    }
    
    func uploadPhoto(data: Data) {
        guard let profile = profile else { return }
        isUploading = true
        
        let base64: String
        if let uiImage = UIImage(data: data) {
            let resizedImage = uiImage.resized(to: CGSize(width: 500, height: 500))
            if let jpegData = resizedImage.jpegData(compressionQuality: 0.7) {
                base64 = "data:image/jpeg;base64," + jpegData.base64EncodedString()
            } else {
                base64 = "data:image/png;base64," + data.base64EncodedString()
            }
        } else {
            base64 = "data:image/png;base64," + data.base64EncodedString()
        }
        let parameters: [String: AnyEncoded] = [
            "patient_id": AnyEncoded(profile.patient_id),
            "name": AnyEncoded(profile.name),
            "phone": AnyEncoded(profile.phone),
            "email": AnyEncoded(profile.email),
            "age": AnyEncoded("\(profile.age ?? 0)"),
            "sex": AnyEncoded(profile.sex),
            "dob": AnyEncoded(profile.dob),
            "profile_image": AnyEncoded(base64)
        ]
        
        NetworkManager.shared.updatePatientProfile(parameters: parameters) { result in
            isUploading = false
            if case .success(let response) = result {
                if response.success {
                    fetchProfile()
                }
            }
        }
    }
    
    private func profileRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold)) // Bolder icon
                .foregroundColor(Color(hex: "3B82F6")) // Royal Blue
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "3B82F6"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "3B82F6").opacity(0.12))
                    .cornerRadius(6)
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.black.opacity(0.85))
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }
}

// MARK: - EDIT PATIENT PROFILE VIEW
struct EditPatientProfileView: View {
    let profile: PatientProfile
    var onUpdate: () -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var phone: String
    @State private var email: String
    @State private var age: String
    @State private var sex: String
    @State private var dob: String
    @State private var dobDate: Date = Date()
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var shouldDeletePhoto = false
    
    init(profile: PatientProfile, onUpdate: @escaping () -> Void) {
        self.profile = profile
        self.onUpdate = onUpdate
        _name = State(initialValue: profile.name)
        _phone = State(initialValue: profile.phone)
        _email = State(initialValue: profile.email)
        _age = State(initialValue: "\(profile.age ?? 0)")
        _sex = State(initialValue: profile.sex)
        _dob = State(initialValue: profile.dob)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: profile.dob) {
            _dobDate = State(initialValue: date)
        }
    }
    
    var body: some View {
        NavigationStack {
                StandardBackground {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Edit Header
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.cyan, lineWidth: 2))
                                } else if let imagePath = profile.profile_image, !imagePath.isEmpty, !shouldDeletePhoto {
                                    let host = URL(string: NetworkManager.shared.baseURL)?.host ?? ""
                                    let finalPath = imagePath.replacingOccurrences(of: "localhost", with: host)
                                    let fullUrl = finalPath.lowercased().hasPrefix("http") ? finalPath : "\(NetworkManager.shared.baseURL)/\(finalPath)"
                                    
                                    AsyncImage(url: URL(string: fullUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                        case .failure(_):
                                            VStack(spacing: 4) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.orange)
                                                Text("FAIL")
                                                    .font(.system(size: 8))
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                        case .empty:
                                            ProgressView().tint(Color.blue)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.cyan, lineWidth: 2))
                                } else {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 100, height: 100)
                                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.cyan)
                                }
                                
                                    PhotosPicker(selection: $selectedItem, matching: .images) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.cyan)
                                            .clipShape(Circle())
                                    }
                                    .onChange(of: selectedItem) { old, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                                selectedImageData = data
                                                shouldDeletePhoto = false
                                            }
                                        }
                                    }
                                    
                                    // Remove Photo Button
                                    if selectedImageData != nil || (profile.profile_image != nil && !shouldDeletePhoto) {
                                        Button {
                                            selectedImageData = nil
                                            selectedItem = nil
                                            shouldDeletePhoto = true
                                        } label: {
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                        }
                                        .offset(x: -80) // Positioned opposite to the camera button
                                    }
                                }
                            .padding(.top, 20)
                            
                            Text("profile_information".localizedPatient())
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black.opacity(0.85))
                        }
                        VStack(spacing: 16) {
                            EditField(title: "full_name".localizedPatient(), text: $name, icon: "person.fill")
                                
                            EditField(title: "phone_number".localizedPatient(), text: $phone, icon: "phone.fill", keyboardType: .phonePad)
                                .onChange(of: phone) { oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered.count > 10 {
                                        phone = String(filtered.prefix(10))
                                    } else {
                                        phone = filtered
                                    }
                                }

                             EditField(title: "email_address".localizedPatient(), text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            
                            HStack(spacing: 16) {
                                EditField(title: "age_label".localizedPatient(), text: $age, icon: "calendar.badge.clock", keyboardType: .numberPad)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("gender".localizedPatient())
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color.gray)
                                        .padding(.leading, 4)
                                    
                                    Menu {
                                        Button("male".localizedPatient()) { sex = "Male" }
                                        Button("female".localizedPatient()) { sex = "Female" }
                                        Button("other_gender".localizedPatient()) { sex = "Other" }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "person.and.arrow.left.and.right")
                                                .foregroundColor(.cyan.opacity(0.8))
                                                .font(.system(size: 14))
                                                .frame(width: 20)
                                            
                                            Text(sex.isEmpty ? "select".localizedPatient() : sex)
                                                .foregroundColor(Color.black.opacity(0.8))
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.cyan.opacity(0.6))
                                        }
                                        .padding()
                                        .background(Color.black.opacity(0.02))
                                        .cornerRadius(14)
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.05), lineWidth: 1))
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("date_of_birth".localizedPatient())
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.gray)
                                    .padding(.leading, 4)
                                
                                DatePicker("", selection: $dobDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.02))
                                    .cornerRadius(14)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.05), lineWidth: 1))
                                    .onChange(of: dobDate) { old, newDate in
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "yyyy-MM-dd"
                                        self.dob = formatter.string(from: newDate)
                                        
                                        // Auto-calculate age
                                        let calendar = Calendar.current
                                        let ageComponents = calendar.dateComponents([.year], from: newDate, to: Date())
                                        if let calculatedAge = ageComponents.year {
                                            self.age = "\(calculatedAge)"
                                        }
                                    }
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                        .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.black.opacity(0.04), lineWidth: 1))
                        
                        // Inline error removed in favor of Alert
                        
                        Button(action: saveChanges) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing))
                                    .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("save_changes".localizedPatient())
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .tracking(1.2)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 60)
                        }
                        .disabled(isSaving)
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
                .navigationTitle("edit_profile_title".localizedPatient())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("cancel".localizedPatient()) { dismiss() }
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                }
                .alert("profile_update_title".localizedPatient(), isPresented: $showAlert) {
                    Button("ok".localizedPatient(), role: .cancel) { }
                } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
            .onChange(of: dob) { old, newValue in
                if let calculatedAge = calculateAge(from: newValue) {
                    self.age = "\(calculatedAge)"
                }
            }
        }
    }
    
    func saveChanges() {
        // Validation
        let nameRegex = "^[a-zA-Z\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !namePredicate.evaluate(with: name) {
            errorMessage = "Name must only contain letters and spaces."
            showAlert = true
            return
        }

        let phoneRegex = "^[6-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !phonePredicate.evaluate(with: phone) {
            errorMessage = "Phone number must be 10 digits and start with 6-9."
            showAlert = true
            return
        }
        
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address (ending with @yahoo.com, @saveetha.com, @outlook.com, @hotmail.com, or @gmail.com)."
            showAlert = true
            return
        }

        isSaving = true
        errorMessage = nil
        
        var profileImageBase64: String? = nil
        if let data = selectedImageData, let uiImage = UIImage(data: data) {
            let resizedImage = uiImage.resized(to: CGSize(width: 500, height: 500))
            if let jpegData = resizedImage.jpegData(compressionQuality: 0.7) {
                profileImageBase64 = "data:image/jpeg;base64," + jpegData.base64EncodedString()
            }
        } else if shouldDeletePhoto {
            profileImageBase64 = "" // Signal removal
        }

        var parameters: [String: AnyEncoded] = [
            "patient_id": AnyEncoded(profile.patient_id),
            "name": AnyEncoded(name),
            "phone": AnyEncoded(phone),
            "email": AnyEncoded(email),
            "age": AnyEncoded(age), 
            "sex": AnyEncoded(sex),
            "dob": AnyEncoded(dob)
        ]
        
        if let base64 = profileImageBase64 {
            parameters["profile_image"] = AnyEncoded(base64)
        }
        
        NetworkManager.shared.updatePatientProfile(parameters: parameters) { result in
            isSaving = false
            switch result {
            case .success(let response):
                if response.success {
                    // Update local storage for immediate persistence
                    UserDefaults.standard.set(name, forKey: "current_patient_name")
                    
                    onUpdate()
                    dismiss()
                } else {
                    errorMessage = response.message ?? "Update failed"
                    showAlert = true
                }
            case .failure(let error):
                errorMessage = "Network Error: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let lowercasedEmail = email.lowercased()
        return lowercasedEmail.hasSuffix("@gmail.com") || 
               lowercasedEmail.hasSuffix("@yahoo.com") || 
               lowercasedEmail.hasSuffix("@saveetha.com") || 
               lowercasedEmail.hasSuffix("@outlook.com") ||
               lowercasedEmail.hasSuffix("@hotmail.com")
    }

    private func calculateAge(from dobString: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthDate = formatter.date(from: dobString) else { return nil }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }
}

private struct EditField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color.gray)
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.cyan.opacity(0.8))
                    .font(.system(size: 14))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .foregroundColor(Color.black.opacity(0.8))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .background(Color.black.opacity(0.02))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
}

struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}
