import SwiftUI
import PhotosUI

struct DoctorDashboardView: View {
    @Binding var isPresented: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // ── MAIN CONTENT AREA ──────────────────────────────────────────
            Group {
                if selectedTab == 0 {
                    NavigationStack {
                        PatientsView(selectedTab: $selectedTab)
                    }
                    .environmentObject(LanguageManager.shared)
                    .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .leading)), removal: .opacity))
                } else if selectedTab == 1 {
                    NavigationStack {
                        DoctorAnalyticsView(selectedTab: $selectedTab)
                    }
                    .environmentObject(LanguageManager.shared)
                    .transition(.opacity)
                } else {
                    NavigationStack {
                        DoctorProfileView(isPresented: $isPresented, selectedTab: $selectedTab)
                    }
                    .environmentObject(LanguageManager.shared)
                    .transition(.asymmetric(insertion: .opacity.combined(with: .move(edge: .trailing)), removal: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - DOCTOR PROFILE VIEW
struct DoctorProfileView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    @State private var doctor: Doctor?
    @State private var isLoading = true
    @State private var isEditing = false
    @EnvironmentObject var languageManager: LanguageManager
    
    // Photo management
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
                            .padding(.top, 50)
                    } else if let doctor = doctor {
                        // Profile Header
                        VStack(spacing: 20) {
                            ZStack {
                                // Animated ring
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
                                        } else if let imagePath = doctor.profile_image, !imagePath.isEmpty {
                                            let host = URL(string: NetworkManager.shared.baseURL)?.host ?? ""
                                            let finalPath = imagePath.replacingOccurrences(of: "localhost", with: host)
                                            let fullUrl = finalPath.lowercased().hasPrefix("http") ? finalPath : "\(NetworkManager.shared.baseURL)/\(finalPath)"
                                            
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
                                        } else {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 120, height: 120)
                                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                                                .overlay(
                                                    VStack(spacing: 4) {
                                                        Image(systemName: "camera.shutter.button.fill")
                                                            .font(.system(size: 32))
                                                        Text("ADD PHOTO")
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
                            
                            Text(doctor.name)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(Color.black.opacity(0.85))
                            
                            Text((doctor.specialization ?? "pediatrician".localizedDoctor()).localizedDoctor())
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.25))
                                .cornerRadius(20)
                        }
                        .padding(.top, 40)
                        .padding(.vertical)
                        
                        // Detail Section
                        VStack(spacing: 12) {
                            profileRow(icon: "envelope.fill", title: "email".localizedDoctor(), value: doctor.email)
                            profileRow(icon: "phone.fill", title: "phone_number".localizedDoctor(), value: doctor.phone ?? "N/A")
                            profileRow(icon: "cross.case.fill", title: "specialization".localizedDoctor(), value: (doctor.specialization ?? "Pediatrician").localizedDoctor())
                        }
                        .padding(.horizontal)
                        
                        // Language Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("language_settings".localizedDoctor())
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3))
                                .padding(.horizontal, 4)
                            
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(Color(hex: "3B82F6"))
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 30)
                                
                                Text("select_language".localizedDoctor())
                                    .font(.body)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Picker("", selection: $languageManager.doctorLanguage) {
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
                        .padding(.top, 10)
                        
                        // Sign Out Button
                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "current_doctor_id")
                            UserDefaults.standard.removeObject(forKey: "current_doctor_name")
                            
                            // Force logout by resetting root Window
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController = UIHostingController(rootView: NavigationStack {
                                    RoleSelectionView()
                                }.environmentObject(LanguageManager.shared))
                                window.makeKeyAndVisible()
                            }
                        }) {
                            Text("sign_out".localizedDoctor())
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
            
            VStack {
                Spacer()
                CustomDoctorTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 10)
        }
        .navigationTitle("your_profile_title".localizedDoctor())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if doctor != nil {
                    Button("edit".localizedDoctor()) {
                        isEditing = true
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            if let doctor = doctor {
                EditDoctorProfileView(doctor: doctor) {
                    fetchDoctorProfile()
                }
            }
        }
        .onAppear {
            fetchDoctorProfile()
        }
    }
    
    private func fetchDoctorProfile() {
        let doctorID = UserDefaults.standard.string(forKey: "current_doctor_id") ?? ""
        
        NetworkManager.shared.getDoctorProfile(doctorID: doctorID) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let response):
                    if let doc = response.doctor {
                        self.doctor = doc
                    } else {
                        // Success but no doctor object in response
                        self.fallbackToLocalProfile(doctorID: doctorID)
                    }
                case .failure:
                    self.fallbackToLocalProfile(doctorID: doctorID)
                }
            }
        }
    }
    
    private func fallbackToLocalProfile(doctorID: String) {
        let email = UserDefaults.standard.string(forKey: "doctor_email") ?? ""
        let name = UserDefaults.standard.string(forKey: "current_doctor_name") ?? "Doctor"
        let spec = UserDefaults.standard.string(forKey: "doctor_specialization") ?? "Pediatrician"
        let phone = UserDefaults.standard.string(forKey: "doctor_phone") ?? ""
        
        self.doctor = Doctor(
            id: 1,
            doctor_id: doctorID,
            name: name,
            email: email,
            phone: phone.isEmpty ? nil : phone,
            specialization: spec,
            profile_image: nil
        )
    }
    
    func uploadPhoto(data: Data) {
        guard let doctor = doctor else { return }
        isUploading = true
        
        let base64 = "data:image/png;base64," + data.base64EncodedString()
        let parameters: [String: AnyEncoded] = [
            "doctor_id": AnyEncoded(doctor.doctor_id),
            "name": AnyEncoded(doctor.name),
            "email": AnyEncoded(doctor.email),
            "phone": AnyEncoded(doctor.phone ?? ""),
            "specialization": AnyEncoded(doctor.specialization ?? ""),
            "profile_image": AnyEncoded(base64)
        ]
        
        NetworkManager.shared.updateDoctorProfile(parameters: parameters) { result in
            isUploading = false
            if case .success(let response) = result, response.success {
                fetchDoctorProfile()
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

// MARK: - EDIT DOCTOR PROFILE VIEW
struct EditDoctorProfileView: View {
    let doctor: Doctor
    var onUpdate: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var specialization: String
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var shouldDeletePhoto = false
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    init(doctor: Doctor, onUpdate: @escaping () -> Void) {
        self.doctor = doctor
        self.onUpdate = onUpdate
        _name = State(initialValue: doctor.name)
        _email = State(initialValue: doctor.email)
        _phone = State(initialValue: doctor.phone ?? "")
        _specialization = State(initialValue: doctor.specialization ?? "")
    }
    
    var body: some View {
        NavigationStack {
            StandardBackground {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Photo Section
                        VStack(spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.cyan, lineWidth: 2))
                                } else if let imagePath = doctor.profile_image, !imagePath.isEmpty, !shouldDeletePhoto {
                                    let host = URL(string: NetworkManager.shared.baseURL)?.host ?? ""
                                    let finalPath = imagePath.replacingOccurrences(of: "localhost", with: host)
                                    let fullUrl = finalPath.lowercased().hasPrefix("http") ? finalPath : "\(NetworkManager.shared.baseURL)/\(finalPath)"
                                    
                                    AsyncImage(url: URL(string: fullUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                        case .failure(_):
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.orange)
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
                                
                                if selectedImageData != nil || (doctor.profile_image != nil && !shouldDeletePhoto) {
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
                                    .offset(x: -80)
                                }
                            }
                            .onChange(of: selectedItem) { old, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                        shouldDeletePhoto = false
                                    }
                                }
                            }
                            
                            Text("edit_profile_details".localizedDoctor())
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 9)
                                .background(Color(hex: "3B82F6"))
                                .cornerRadius(12)
                            
                            Text("update_professional_info".localizedDoctor())
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "64748B"))
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            EditField(title: "full_name".localizedDoctor(), text: $name, icon: "person.fill")
                            
                            EditField(title: "email_address".localizedDoctor(), text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            
                            EditField(title: "phone_number".localizedDoctor(), text: $phone, icon: "phone.fill", keyboardType: .phonePad)
                                .onChange(of: phone) { oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered.count > 10 {
                                        phone = String(filtered.prefix(10))
                                    } else {
                                        phone = filtered
                                    }
                                }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("specialization".localizedDoctor())
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "64748B"))
                                    .padding(.leading, 4)
                                
                                Menu {
                                    Button("pediatrician".localizedDoctor()) { specialization = "Pediatrician" }
                                    Button("child_psychiatrist".localizedDoctor()) { specialization = "Child Psychiatrist" }
                                    Button("speech_therapist".localizedDoctor()) { specialization = "Speech Therapist" }
                                    Button("occupational_therapist".localizedDoctor()) { specialization = "Occupational Therapist" }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "cross.case.fill")
                                            .foregroundColor(.cyan.opacity(0.8))
                                            .font(.system(size: 14))
                                            .frame(width: 20)
                                        
                                        Text(specialization.isEmpty ? "select_specialization".localizedDoctor() : specialization.localizedDoctor())
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
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                        
                        Button(action: saveChanges) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing))
                                    .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("save_changes".localizedDoctor())
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
            .navigationTitle("edit_doctor_profile_title".localizedDoctor())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localizedDoctor()) { dismiss() }
                        .foregroundColor(Color(hex: "64748B"))
                }
            }
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Check your details and try again.")
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

        let lowercasedEmail = email.lowercased()
        if !(lowercasedEmail.hasSuffix("@gmail.com") || lowercasedEmail.hasSuffix("@yahoo.com") || lowercasedEmail.hasSuffix("@saveetha.com") || lowercasedEmail.hasSuffix("@outlook.com") || lowercasedEmail.hasSuffix("@hotmail.com")) {
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
            "doctor_id": AnyEncoded(doctor.doctor_id),
            "name": AnyEncoded(name),
            "email": AnyEncoded(email),
            "phone": AnyEncoded(phone),
            "specialization": AnyEncoded(specialization)
        ]
        
        if let base64 = profileImageBase64 {
            parameters["profile_image"] = AnyEncoded(base64)
        }
        
        NetworkManager.shared.updateDoctorProfile(parameters: parameters) { result in
            isSaving = false
            switch result {
            case .success(let response):
                if response.success {
                    // Update local storage
                    UserDefaults.standard.set(name, forKey: "current_doctor_name")
                    UserDefaults.standard.set(email, forKey: "doctor_email")
                    UserDefaults.standard.set(phone, forKey: "doctor_phone")
                    UserDefaults.standard.set(specialization, forKey: "doctor_specialization")
                    
                    onUpdate()
                    dismiss()
                } else {
                    errorMessage = response.message ?? "Update failed"
                    showAlert = true
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}

// Reuse or define EditField for consistency
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

