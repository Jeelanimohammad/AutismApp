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
                    SuccessView(
                        resultMessage: viewModel.resultMessage,
                        yesCount: viewModel.yesCount,
                        totalCount: viewModel.totalCount
                    )
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
    var yesCount: Int = 0
    var totalCount: Int = 0
    
    @State private var showResultDetail = false
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    var riskLevel: (text: String, color: Color) {
        if yesCount >= 5 {
            return ("High", .red)
        } else if yesCount >= 2 {
            return ("Moderate", .orange)
        } else {
            return ("Low", .green)
        }
    }
    
    var recommendation: String {
        if yesCount >= 3 {
            return "The pattern suggests strong behavioral indicators. Professional consultation is recommended."
        } else {
            return "The pattern suggests mild or low indicators. Continued monitoring is advised."
        }
    }
    
    var body: some View {
        Group {
            if !showResultDetail {
                // ── PHASE 4: SUBMISSION SUCCESS SCREEN ──
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        // Blue Checkmark Icon
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.0, green: 0.78, blue: 0.88), Color(red: 0.1, green: 0.5, blue: 1.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Responses Saved Successfully")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "0F172A"))
                                .multilineTextAlignment(.center)
                            
                            Text("Your assessment has been submitted. You can now view the details below.")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "64748B"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        
                        VStack(spacing: 12) {
                            // View Result Button
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showResultDetail = true
                                }
                            }) {
                                Text("View Result")
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 0.0, green: 0.78, blue: 0.88), Color(red: 0.1, green: 0.5, blue: 1.0)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(14)
                                    .shadow(color: Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.3), radius: 8, y: 4)
                            }
                            
                            // Back to Home Button
                            Button(action: navigateToDashboard) {
                                Text("Back to Home")
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.clear)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(red: 0.1, green: 0.5, blue: 1.0), lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.top, 12)
                    }
                    .padding(28)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            } else {
                // ── PHASE 5: DETAILED ASSESSMENT RESULT SCREEN ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Banner Header
                        VStack(spacing: 6) {
                            Text("Assessment Result")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Review the analysis below")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.78, blue: 0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        
                        // White Main Analysis Card
                        VStack(spacing: 20) {
                            // Accent Line
                            Capsule()
                                .fill(Color(red: 0.1, green: 0.5, blue: 1.0))
                                .frame(width: 50, height: 4)
                                .padding(.top, 8)
                            
                            // 1. Clinical Result Section
                            VStack(spacing: 10) {
                                Text("Clinical Result")
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                                    .foregroundColor(.green)
                                
                                Text(resultMessage ?? "Your child may require further diagnostic evaluation.")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.05, green: 0.5, blue: 0.3))
                                    .multilineTextAlignment(.center)
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.12))
                                    .cornerRadius(14)
                            }
                            
                            Divider()
                            
                            // 2. AI Summary Section
                            VStack(spacing: 12) {
                                Text("AI Summary")
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.85))
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 8) {
                                        Text("•").foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.88)).bold()
                                        Text("Screening Score: \(yesCount) / \(totalCount)")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.black.opacity(0.85))
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Text("•").foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.88)).bold()
                                        Text("Indicators Detected: \(yesCount)")
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(Color.black.opacity(0.85))
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Text("•").foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.88)).bold()
                                        HStack(spacing: 4) {
                                            Text("Risk Level: ")
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(Color.black.opacity(0.85))
                                            Text(riskLevel.text)
                                                .font(.system(size: 14, weight: .black, design: .rounded))
                                                .foregroundColor(riskLevel.color)
                                        }
                                    }
                                    
                                    Divider().padding(.vertical, 4)
                                    
                                    Text(recommendation)
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color.gray)
                                        .lineSpacing(3)
                                }
                                .padding(18)
                                .background(Color.black.opacity(0.03))
                                .cornerRadius(16)
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        
                        // Close Button
                        Button(action: navigateToDashboard) {
                            Text("Close")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.1, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.78, blue: 0.88)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(26)
                                .shadow(color: Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
    
    private func navigateToDashboard() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let patientID = UserDefaults.standard.string(forKey: "current_patient_id") ?? ""
            let doctorID = UserDefaults.standard.string(forKey: "current_doctor_id") ?? ""
            
            window.rootViewController = UIHostingController(rootView: NavigationStack {
                if !doctorID.isEmpty && patientID.isEmpty {
                    DoctorDashboardView(isPresented: .constant(true))
                        .environmentObject(LanguageManager.shared)
                } else {
                    PatientDashboardView(isPresented: .constant(true), patientID: patientID)
                        .environmentObject(LanguageManager.shared)
                }
            })
            window.makeKeyAndVisible()
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
