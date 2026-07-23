import SwiftUI

//////////////////////////////////////////////////////////////
// MARK: - AGE SELECTION
//////////////////////////////////////////////////////////////

struct AgeOptionItem: Hashable {
    let value: String
    let title: String
    let subtitle: String
    let systemImage: String
    let gradientColors: [Color]
}

struct AgeConfiguration: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var ageOptions: [AgeOptionItem] {
        [
            AgeOptionItem(
                value: "< 3", 
                title: "infant_toddler".localizedPatient(), 
                subtitle: "under_3_years".localizedPatient(), 
                systemImage: "stroller.fill",
                gradientColors: [Color(hex: "FF9100"), Color(hex: "FFAB40")] // Vibrant Amber/Gold
            ),
            AgeOptionItem(
                value: "> 3", 
                title: "older_child".localizedPatient(), 
                subtitle: "older_3_years".localizedPatient(), 
                systemImage: "figure.walk",
                gradientColors: [Color(hex: "2979FF"), Color(hex: "536DFE")] // Professional Azure Blue
            )
        ]
    }
    
    @State private var selectedAge: String? = nil
    @State private var goNext = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        StandardBackground {
            VStack(spacing: 35) {
                
                Spacer()
                
                // 🧩 GLOWING ICON HEADER
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.78, blue: 0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)
                        .opacity(0.4)
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.78, blue: 0.88)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .clear, radius: 0)
                }
                
                VStack(spacing: 12) {
                    Text("select_age_group".localizedPatient())
                        .font(.system(size: 32, weight: .black, design: .rounded)) // Max bold, larger size
                        .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1) // subtle drop shadow
                    
                    Text("age_bracket_description".localizedPatient())
                        .font(.system(size: 15, weight: .heavy, design: .rounded)) // Bolder
                        .foregroundColor(Color(red: 0.05, green: 0.2, blue: 0.4)) // Darker navy/slate
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // 🗂️ SELECTION CARDS
                VStack(spacing: 16) {
                    ForEach(ageOptions, id: \.value) { option in
                        PremiumAgeButton(
                            option: option,
                            isSelected: selectedAge == option.value
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedAge = option.value
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // ⏭️ CONTINUE BUTTON
                Button(action: {
                    if selectedAge != nil {
                        goNext = true
                    }
                }) {
                    ZStack {
                        Text("continue".localizedPatient())
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Group {
                                    if selectedAge == nil {
                                        Color.black.opacity(0.05)
                                    } else {
                                        LinearGradient(
                                            colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.78, blue: 0.88)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                }
                            )
                            .foregroundColor(selectedAge == nil ? Color.gray.opacity(0.5) : .white)
                            .cornerRadius(18)
                            .shadow(color: .clear, radius: 0)
                    }
                }
                .disabled(selectedAge == nil)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.85))
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .clear, radius: 0)
                }
            }
        }
        .navigationDestination(isPresented: $goNext) {
            if let age = selectedAge {
                SymptomAssessmentView(ageGroup: age)
            }
        }
    }
}

// MARK: - PREMIUM AGE BUTTON
struct PremiumAgeButton: View {
    let option: AgeOptionItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon Box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: option.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: option.gradientColors[0].opacity(0.2), radius: 5)
                    
                    Image(systemName: option.systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(option.title)
                        .font(.system(size: 19, weight: .black, design: .rounded)) // Max bold
                        .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                    
                    Text(option.subtitle)
                        .font(.system(size: 14, weight: .heavy, design: .rounded)) // Bolder
                        .foregroundColor(Color(red: 0.05, green: 0.2, blue: 0.4)) // Darker navy/slate
                }
                
                Spacer()
                
                // Radio Indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? option.gradientColors[0] : Color.black.opacity(0.1), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(option.gradientColors[0])
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white)
                }
            )
            .cornerRadius(22)
            .shadow(color: .clear, radius: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? option.gradientColors[0] : Color.black.opacity(0.04), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: .clear, radius: 0)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}

// MARK: - DYNAMIC SYMPTOM ASSESSMENT VIEW
struct SymptomAssessmentView: View {
    let ageGroup: String
    @StateObject private var viewModel = AssessmentViewModel()
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        StandardBackground {
            VStack {
                if viewModel.isLoading {
                    ProgressView("loading_symptoms".localizedPatient())
                        .foregroundColor(Color.black.opacity(0.85))
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .foregroundColor(Color.black.opacity(0.85))
                            .multilineTextAlignment(.center)
                        Button("retry".localizedPatient()) {
                            viewModel.fetchSymptoms(ageGroup: ageGroup)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.78, blue: 0.88)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(color: .clear, radius: 0)
                    }
                    .padding()
                } else if viewModel.isCompleted {
                    SuccessView(resultMessage: viewModel.resultMessage)
                } else if let symptom = viewModel.currentSymptom {
                    VStack(spacing: 25) {
                        // Progress
                        ProgressView(value: viewModel.progress)
                            .tint(Color(red: 0.1, green: 0.5, blue: 1.0))
                            .padding(.horizontal)
                        
                        Text(String(format: "question_counter".localizedPatient(), viewModel.currentSymptomIndex + 1, viewModel.symptoms.count))
                            .font(.caption)
                            .foregroundColor(Color.gray)
                        
                        // 🎨 SMART IMAGE LOADER
                        VStack(spacing: 10) {
                            Group {
                                // 1. Try local asset first (using convention 'child' + id)
                                if let localImage = UIImage(named: "child\(symptom.id)") {
                                    Image(uiImage: localImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 220)
                                        .cornerRadius(15)
                                        .shadow(color: .clear, radius: 0)
                                }
                                // 2. Try remote URL
                                else if let imageURLStr = symptom.image_url, let url = URL(string: imageURLStr) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .tint(Color.blue)
                                                .frame(height: 220)
                                                .frame(maxWidth: .infinity)
                                                .background(Color.white)
                                                .cornerRadius(15)
                                                .shadow(color: .clear, radius: 0)
                                        case .success(let image):
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(height: 220)
                                                .cornerRadius(15)
                                                .shadow(color: .clear, radius: 0)
                                        case .failure(_):
                                            ImagePlaceholder()
                                        @unknown default:
                                            ImagePlaceholder()
                                        }
                                    }
                                }
                                // 3. Last Resort
                                else {
                                    ImagePlaceholder()
                                }
                            }

                            // ── Symptom name label under image ──
                            Text(symptom.symptom_name.localizedPatient())
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.black.opacity(0.85))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .clear, radius: 0)
                                .padding(.horizontal)
                        }
                        .padding(.horizontal)

                        // Question prompt
                        Text("exhibit_symptom".localizedPatient())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.black.opacity(0.85))
                            .padding(.horizontal)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .clear, radius: 0)
                            .padding(.horizontal)
                        
                        // Response Buttons
                        HStack(spacing: 20) {
                            Button {
                                viewModel.recordResponse(answer: "Yes", context: modelContext)
                            } label: {
                                Label("yes".localizedPatient(), systemImage: "checkmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .shadow(color: .clear, radius: 0)
                            }
                            
                            Button {
                                viewModel.recordResponse(answer: "No", context: modelContext)
                            } label: {
                                Label("no".localizedPatient(), systemImage: "xmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .shadow(color: .clear, radius: 0)
                            }
                        }
                        .padding(.horizontal, 30)

                        Spacer()
                    }
                    .padding(.top)
                } else if viewModel.symptoms.isEmpty && !viewModel.isLoading {
                    Text("no_symptoms_found".localizedPatient())
                        .foregroundColor(Color.gray)
                }
            }
        }
        .navigationTitle("assessment".localizedPatient())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if viewModel.currentSymptomIndex > 0 && !viewModel.isCompleted {
                        viewModel.goBack()
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.85))
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .clear, radius: 0)
                }
            }
        }
        .onAppear {
            viewModel.fetchSymptoms(ageGroup: ageGroup)
        }
    }
}

struct SuccessView: View {
    let resultMessage: String?
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text(resultMessage ?? "assessment_completed".localizedPatient())
                .font(.title2)
                .bold()
                .foregroundColor(Color.black.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("data_saved_review".localizedPatient())
                .multilineTextAlignment(.center)
                .foregroundColor(Color.gray)
                .padding(.horizontal)
            
            Button("back_to_dashboard".localizedPatient()) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    
                    let patientID = UserDefaults.standard.string(forKey: "current_patient_id") ?? ""
                    let doctorID = UserDefaults.standard.string(forKey: "current_doctor_id") ?? ""
                    
                    window.rootViewController = UIHostingController(rootView: NavigationStack {
                        // Check which user is logged in to return them to the correct dashboard
                        if !doctorID.isEmpty && patientID.isEmpty {
                            DoctorDashboardView(isPresented: .constant(true))
                                .environmentObject(LanguageManager.shared)
                        } else {
                            // Default to patient dashboard if patient session exists
                            PatientDashboardView(isPresented: .constant(true), patientID: patientID)
                                .environmentObject(LanguageManager.shared)
                        }
                    })
                    window.makeKeyAndVisible()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.78, blue: 0.88)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(color: .clear, radius: 0)
            .padding(.horizontal)
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - PREVIEW
//////////////////////////////////////////////////////////////

#Preview {
    NavigationStack {
        AgeConfiguration()
    }
}

// MARK: - IMAGE PLACEHOLDER
struct ImagePlaceholder: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(Color.gray.opacity(0.5))
            Text("Medical visual loading...")
                .font(.caption)
                .foregroundColor(Color.gray)
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .clear, radius: 0)
    }
}
