import SwiftUI
import UIKit

// MARK: - PATIENT REPORTS LIST VIEW
struct PatientReportsListView: View {
    let patient: Patient
    @StateObject private var viewModel = PatientsViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var assessmentToDelete: PatientAssessment? = nil
    
    var body: some View {
        ZStack {
            // ── LIGHT AURA ENVIRONMENT ──────────────────────────
            LinearGradient(
                colors: [Color.white, Color(hex: "F0F9FF"), Color(hex: "E0F2FE")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // ── HERO PATIENT CARD ─────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text(patient.name)
                            .font(.system(size: 17, weight: .black, design: .rounded)) // High weight
                            .foregroundColor(Color(hex: "0F172A")) // Near black
                        
                        HStack(spacing: 8) {
                            Image(systemName: "number.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "3B82F6"))
                            Text("ID: \(patient.patient_id)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "475569"))
                        }
                    }
                    .padding(.top, 20)
                    
                    if viewModel.isLoading {
                        ProgressView().tint(.blue).padding(.top, 40)
                    } else if viewModel.assessmentHistory.isEmpty {
                        VStack(spacing: 32) {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 120, height: 120).shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundColor(Color(hex: "3B82F6"))
                            }
                            Text("No history recorded yet.")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "64748B"))
                        }
                        .padding(.top, 60)
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("clinical_chronology".localizedDoctor())
                                .font(.system(size: 11, weight: .black, design: .monospaced))
                                .foregroundColor(Color(hex: "3B82F6").opacity(0.6))
                                .tracking(2)
                                .padding(.leading, 4)

                            VStack(spacing: 16) {
                                ForEach(viewModel.assessmentHistory, id: \.self.created_at) { assessment in
                                    NavigationLink {
                                        AssessmentDetailView(assessmentId: assessment.id, patientID: patient.patient_id, patientName: patient.name) {
                                            viewModel.removeAssessmentLocally(assessmentID: assessment.id)
                                        }
                                        .environmentObject(LanguageManager.shared)
                                    } label: {
                                        HStack(spacing: 20) {
                                            // Status Icon
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color(hex: "3B82F6").opacity(0.1))
                                                    .frame(width: 52, height: 52)
                                                
                                                Image(systemName: assessment.has_feedback == 1 ? "checkmark.seal.fill" : "circle.dotted")
                                                    .font(.system(size: 22, weight: .bold))
                                                    .foregroundColor(Color(hex: "3B82F6"))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(assessment.result_message.localizedDoctor().capitalized)
                                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                                    .foregroundColor(Color(hex: "1E293B"))
                                                
                                                Text(assessment.created_at)
                                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                    .foregroundColor(Color(hex: "64748B"))
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(Color(hex: "3B82F6"))
                                        }
                                        .padding(20)
                                        .background(Color.white)
                                        .cornerRadius(24)
                                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            assessmentToDelete = assessment
                                        } label: {
                                            Label("delete".localizedDoctor(), systemImage: "trash")
                                        }
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            assessmentToDelete = assessment
                                        } label: {
                                            Label("Delete Report", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .onAppear {
                viewModel.fetchAssessmentHistory(patientID: patient.patient_id)
            }
            .alert(item: $assessmentToDelete) { assessment in
                Alert(
                    title: Text("delete_report".localizedDoctor()),
                    message: Text("delete_report_message".localizedDoctor()),
                    primaryButton: .destructive(Text("delete".localizedDoctor())) {
                        // Optimistic UI update
                        withAnimation {
                            viewModel.removeAssessmentLocally(assessmentID: assessment.id)
                        }
                        
                        NetworkManager.shared.deleteAssessment(assessmentID: assessment.id) { result in
                            DispatchQueue.main.async {
                                if case .failure = result {
                                    // Re-fetch only on failure
                                    viewModel.fetchAssessmentHistory(patientID: patient.patient_id)
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("cancel".localizedDoctor()))
                )
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - PATIENTS VIEW
struct PatientsView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = PatientsViewModel()
    @State private var showAddPatient = false
    @State private var profileImage: String? = nil
    @State private var searchText = ""
    @State private var patientToDelete: Patient? = nil
    @State private var showingDeleteAlert = false
    @EnvironmentObject var languageManager: LanguageManager

    var doctorName: String {
        UserDefaults.standard.string(forKey: "current_doctor_name") ?? "Doctor"
    }

    var filteredPatients: [Patient] {
        viewModel.patients.filter {
            searchText.isEmpty ? true : $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "good_morning".localizedDoctor()
        case 12..<17: return "good_afternoon".localizedDoctor()
        default: return "good_evening".localizedDoctor()
        }
    }

    var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "sun.max.fill"
        case 12..<17: return "sun.horizon.fill"
        default: return "moon.stars.fill"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color.white, Color(hex: "F0F9FF"), Color(hex: "E0F2FE")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── GREETING HEADER ──────────────────────────
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(greeting), \("dr".localizedDoctor())\(doctorName.split(separator: " ").first ?? "Doctor")")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "0F172A"))
                        
                        Text("Here is your clinical overview for today.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                    
                    Spacer()
                    
                    Button(action: { showAddPatient = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Register Patient")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(hex: "10B981"))
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "10B981").opacity(0.3), radius: 6, y: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // ── STAT CARDS ROW ────────────────────────────
                let totalPatients        = viewModel.patients.count
                let advisedPatients      = viewModel.patients.filter { ($0.has_advice ?? 0) > 0 && ($0.pending_reviews ?? 0) == 0 }.count
                let pendingPatientsCount = viewModel.patients.filter { ($0.pending_reviews ?? 0) > 0 || ($0.has_advice ?? 0) == 0 }.count

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        DoctorStatCard(
                            icon: "person.3.fill",
                            value: "\(totalPatients)",
                            label: "total_patients".localizedDoctor(),
                            gradient: [Color(hex: "2563EB"), Color(hex: "3B82F6")]
                        )
                        DoctorStatCard(
                            icon: "waveform.path.ecg",
                            value: "\(advisedPatients)",
                            label: "advice_given".localizedDoctor(),
                            gradient: [Color(hex: "06B6D4"), Color(hex: "10B981")]
                        )
                        DoctorStatCard(
                            icon: "heart.fill",
                            value: "\(pendingPatientsCount)",
                            label: "pending_review".localizedDoctor(),
                            gradient: [Color(hex: "EA580C"), Color(hex: "F59E0B")]
                        )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)

                // ── ERROR BANNER ─────────────────────────────────────────
                if let error = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Button { viewModel.errorMessage = nil } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                // ── SEARCH BAR ───────────────────────────────────────────
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "94A3B8"))
                    TextField("", text: $searchText, prompt: Text("search_patients".localizedDoctor()).foregroundColor(Color(hex: "94A3B8")))
                        .foregroundColor(Color(hex: "1E293B"))
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.06), radius: 10, y: 5)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // ── PATIENT LIST ─────────────────────────────────────────
                List {
                    Section {
                        ForEach(filteredPatients) { patient in
                            NavigationLink(destination: PatientReportsListView(patient: patient).environmentObject(LanguageManager.shared)) {
                                MinimalistPatientRow(patient: patient)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    patientToDelete = patient
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Remove", systemImage: "trash.fill")
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    patientToDelete = patient
                                    showingDeleteAlert = true
                                } label: {
                                    Label("Delete Patient", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text("my_patients".localizedDoctor())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.18))
                            .cornerRadius(8)
                            .textCase(nil)
                            .padding(.bottom, 8)
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
                .scrollIndicators(.hidden)
            }
            
            VStack {
                Spacer()
                CustomDoctorTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 10)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddPatient) {
            AddPatientView { _ in viewModel.fetchPatients() }
        }
        .onAppear {
            viewModel.fetchPatients()
            fetchDoctorProfile()
        }
        .alert("permanent_deletion".localizedDoctor(), isPresented: $showingDeleteAlert) {
            Button("cancel".localizedDoctor(), role: .cancel) { }
            Button("delete_permanently".localizedDoctor(), role: .destructive) {
                if let patient = patientToDelete {
                    viewModel.deletePatient(patientID: patient.patient_id)
                    // Reset selection
                    patientToDelete = nil
                }
            }
        } message: {
            if let patient = patientToDelete {
                Text(String(format: "confirm_delete_patient".localizedDoctor(), patient.name))
            }
        }
    }

    private func fetchDoctorProfile() {
        let doctorID = UserDefaults.standard.string(forKey: "current_doctor_id") ?? ""
        NetworkManager.shared.getDoctorProfile(doctorID: doctorID) { result in
            if case .success(let response) = result {
                DispatchQueue.main.async {
                    self.profileImage = response.doctor?.profile_image
                }
            }
        }
    }
}

// MARK: - DOCTOR STAT CARD
struct DoctorStatCard: View {
    let icon: String
    let value: String
    let label: String
    let gradient: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(0.8)
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(18)
        .frame(width: 150)
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: gradient.first!.opacity(0.4), radius: 12, y: 6)
    }
}

// MARK: - MINIMALIST PATIENT ROW
struct MinimalistPatientRow: View {
    let patient: Patient

    var body: some View {
        HStack(spacing: 16) {
            // Teal-blue Gradient Avatar Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "0D9488"), Color(hex: "0284C7")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Text(String(patient.name.prefix(1)).uppercased())
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(patient.name.capitalized)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0F172A"))
                
                Text("ID: #\(patient.patient_id.suffix(4))")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "64748B"))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if let age = patient.age {
                    Text("\(age) YRS")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "2563EB"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "DBEAFE"))
                        .cornerRadius(12)
                }
                
                let pendingCount = (patient.pending_reviews ?? 0) > 0 ? (patient.pending_reviews ?? 0) : ((patient.has_advice ?? 0) == 0 ? 1 : 0)
                if pendingCount > 0 {
                    Text("\(pendingCount) PENDING")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "D97706"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(hex: "FEF3C7"))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - POLYGON SHAPE
struct Polygon: Shape {
    let sides: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let angle = 2 * .pi / CGFloat(sides)

        for i in 0..<sides {
            let x = center.x + radius * cos(CGFloat(i) * angle - .pi / 2)
            let y = center.y + radius * sin(CGFloat(i) * angle - .pi / 2)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct DoctorAdviceSection: View {
    let patientID: String
    var assessmentID: Int? = nil
    var showAddButton: Bool = true
    @StateObject private var adviceViewModel = PatientAdviceViewModel()
    @State private var newAdviceText = ""
    @State private var isAddingAdvice = false
    var isDoctor: Bool = true // Added to allow role-based localization
    
    private func l(_ key: String) -> String {
        return isDoctor ? key.localizedDoctor() : key.localizedPatient()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Color(hex: "2563EB"))
                    Text(l("clinical_guidance").uppercased())
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Color(hex: "2563EB"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "2563EB").opacity(0.1))
                        .cornerRadius(8)
                }
                Spacer()
                if showAddButton && isDoctor {
                    Button {
                        withAnimation(.spring()) { isAddingAdvice.toggle() }
                    } label: {
                        ZStack {
                            Circle().fill(Color(hex: "38BDF8").opacity(isAddingAdvice ? 0.2 : 0.1)).frame(width: 32, height: 32)
                            Image(systemName: isAddingAdvice ? "xmark" : "plus")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(Color(hex: "38BDF8"))
                        }
                    }
                }
            }
            
            if isAddingAdvice {
                VStack(spacing: 16) {
                    TextEditor(text: $newAdviceText)
                        .font(.system(size: 14, weight: .medium))
                        .frame(height: 120)
                        .padding(12)
                        .background(Color(hex: "F8FAFC"))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "38BDF8").opacity(0.2), lineWidth: 1))
                    
                    Button {
                        let docName = UserDefaults.standard.string(forKey: "current_doctor_name") ?? "Doctor"
                        let docId = UserDefaults.standard.string(forKey: "current_doctor_id") ?? "unknown"
                        adviceViewModel.selectedPatientID = patientID
                        adviceViewModel.addAdvice(text: newAdviceText, doctorName: docName, doctorID: docId, assessmentID: assessmentID)
                        newAdviceText = ""
                        isAddingAdvice = false
                    } label: {
                        Text(l("post_advice"))
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "38BDF8"))
                            .cornerRadius(12)
                            .shadow(color: Color(hex: "38BDF8").opacity(0.2), radius: 10, y: 5)
                    }
                    .disabled(newAdviceText.isEmpty)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if adviceViewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity)
            } else if adviceViewModel.adviceList.isEmpty {
                HStack {
                    Spacer(); Text(l("no_clinical_notes")).font(.system(size: 13, weight: .medium)).foregroundColor(Color(hex: "94A3B8")); Spacer()
                }.padding(.vertical, 10)
            } else {
                VStack(spacing: 12) {
                    ForEach(adviceViewModel.adviceList) { advice in
                        VStack(alignment: .leading, spacing: 14) {
                            Text(advice.advice_text)
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "1E293B"))
                                .lineSpacing(4)
                            
                            HStack {
                                Text("\(l("dr"))\(advice.doctor_name ?? "Anonymous")".uppercased())
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                                    .foregroundColor(Color(hex: "38BDF8"))
                                Spacer()
                                Text(advice.created_at ?? "")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color(hex: "94A3B8"))
                            }
                        }
                        .padding(18)
                        .background(Color(hex: "F8FAFC"))
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "38BDF8").opacity(0.1), lineWidth: 1))
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, y: 5)
        .onAppear {
            adviceViewModel.selectedPatientID = patientID
            adviceViewModel.selectedAssessmentID = assessmentID
            adviceViewModel.fetchAdvice()
        }
    }
}

// MARK: - HELPERS
struct IdentifiableInt: Identifiable {
    let id: Int
}

// MARK: - ASSESSMENT DETAIL VIEW
struct AssessmentDetailView: View {
    let assessmentId: Int
    
    private func l(_ key: String) -> String {
        return isDoctor ? key.localizedDoctor() : key.localizedPatient()
    }
    let patientID: String
    var patientName: String? = nil
    var isDoctor: Bool = true
    var onDelete: (() -> Void)? = nil
    @State private var details: AssessmentDetailsResponse?
    @State private var isLoading = true
    @State private var aiInsight: String = ""
    @State private var isAILoading = false
    @State private var isSharing = false
    @State private var showingDeleteAlert = false
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        StandardBackground {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView().tint(.blue).frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let details = details {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // ── SUMMARY HEADER (LIGHT CARD) ────────────
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text(l("clinical_analysis").uppercased())
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color(hex: "3B82F6"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "3B82F6").opacity(0.12))
                                        .cornerRadius(8)
                                    
                                    Spacer()
                                    Text("ID: #\(patientID.suffix(4))")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(hex: "64748B"))
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(l(details.result_message))
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color(hex: "1E293B"))
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .font(.caption)
                                        Text("\(l("timeline")): \(details.created_at)")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    .foregroundColor(Color(hex: "64748B"))
                                }
                            }
                            .padding(30)
                            .background(Color.white)
                            .cornerRadius(32)
                            .shadow(color: Color.black.opacity(0.06), radius: 15, y: 10)
                            
                            // ── SYMPTOM MATRIX (LIGHT) ──────────────────────────────
                            VStack(alignment: .leading, spacing: 24) {
                                Text(l("symptom_matrix").uppercased())
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color(hex: "475569"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(hex: "475569").opacity(0.10))
                                    .cornerRadius(8)
                                
                                VStack(spacing: 16) {
                                    ForEach(Array(details.responses.enumerated()), id: \.element.symptom_name) { index, resp in
                                        VStack(spacing: 16) {
                                            HStack(alignment: .top) {
                                                Text(l(resp.symptom_display_name ?? resp.symptom_name))
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundColor(Color(hex: "334155"))
                                                    .multilineTextAlignment(.leading)
                                                Spacer()
                                                HStack(spacing: 4) {
                                                    Image(systemName: resp.response.lowercased() == "yes" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                        .font(.system(size: 10, weight: .bold))
                                                    Text(l(resp.response).uppercased())
                                                        .font(.system(size: 11, weight: .black))
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(resp.response.lowercased() == "yes" ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                                                .foregroundColor(resp.response.lowercased() == "yes" ? Color.green : Color.red)
                                                .cornerRadius(8)
                                            }
                                            
                                            // Add neat dividers between all except the last item
                                            if index < details.responses.count - 1 {
                                                Divider().opacity(0.6)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(32)
                            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 5)
                            
                            // ── ADVICE SECTION ──────────────────────────────
                            DoctorAdviceSection(patientID: patientID, assessmentID: assessmentId, showAddButton: isDoctor, isDoctor: isDoctor)
                                .padding(.bottom, 40)
                                .colorScheme(.light)
                        }
                        .padding(24)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorStyle(.dark) // Custom helper for toolbar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if details != nil {
                    Menu {
                        Button {
                            isSharing = true
                        } label: {
                            Label(l("download_report"), systemImage: "arrow.down.doc.fill")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label(l("delete_report"), systemImage: "trash.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .alert(l("delete_report_confirm"), isPresented: $showingDeleteAlert) {
            Button(l("cancel"), role: .cancel) { }
            Button(l("delete_report"), role: .destructive) {
                NetworkManager.shared.deleteAssessment(assessmentID: assessmentId) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            if response.success {
                                onDelete?()
                                dismiss()
                            }
                        case .failure(_):
                            // Silent failure for now, but we don't dismiss or remove locally
                            break
                        }
                    }
                }
            }
        } message: {
            Text(l("delete_report_message"))
        }
        .sheet(isPresented: $isSharing) {
            if let pdfURL = generatePDF() {
                ShareSheet(activityItems: [pdfURL])
            } else {
                ShareSheet(activityItems: [reportText])
            }
        }
        .onAppear {
            NetworkManager.shared.getAssessmentDetails(assessmentID: assessmentId) { result in
                isLoading = false
                if case .success(let data) = result { 
                    self.details = data 
                    fetchAIInsight(responses: data.responses)
                }
            }
        }
    }
    
    private func fetchAIInsight(responses: [PatientSymptomResponse]) {
        isAILoading = true
        GeminiService.shared.generateInsight(responses: responses) { insight in
            withAnimation(.easeIn) {
                self.aiInsight = insight
                self.isAILoading = false
            }
        }
    }
    
    private func generatePDF() -> URL? {
        guard let details = details else { return nil }
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; color-adjust: exact !important; box-sizing: border-box; }
                html, body {
                    background-color: #0F172A !important;
                    color: #F8FAFC !important;
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                    margin: 0;
                    padding: 20px;
                }
                .card {
                    background-color: #1E293B !important;
                    border: 1px solid #334155 !important;
                    border-radius: 16px;
                    padding: 24px;
                    box-shadow: 0 10px 25px rgba(0,0,0,0.3);
                }
                .header {
                    border-bottom: 1px solid #334155;
                    padding-bottom: 16px;
                    margin-bottom: 20px;
                }
                .logo {
                    color: #06B6D4 !important;
                    font-size: 24px;
                    font-weight: 900;
                    letter-spacing: -0.5px;
                }
                .sub {
                    color: #94A3B8 !important;
                    font-size: 13px;
                    margin-top: 4px;
                }
                .section-title {
                    font-size: 13px;
                    font-weight: 800;
                    text-transform: uppercase;
                    color: #06B6D4 !important;
                    letter-spacing: 1px;
                    margin: 20px 0 10px 0;
                }
                .info-box {
                    background-color: #0F172A !important;
                    border: 1px solid #334155 !important;
                    border-radius: 12px;
                    padding: 16px;
                    margin-bottom: 20px;
                }
                .info-line {
                    margin-bottom: 8px;
                    font-size: 14px;
                }
                .info-label { color: #94A3B8 !important; }
                .info-val { color: #F8FAFC !important; font-weight: 700; }
                .badge {
                    display: inline-block;
                    padding: 4px 12px;
                    border-radius: 20px;
                    font-size: 12px;
                    font-weight: 800;
                    background-color: rgba(6,182,212,0.25) !important;
                    color: #06B6D4 !important;
                    border: 1px solid rgba(6,182,212,0.5);
                }
                table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 13px; }
                th, td { text-align: left; padding: 10px 12px; border-bottom: 1px solid #334155 !important; }
                th { color: #94A3B8 !important; font-size: 11px; text-transform: uppercase; }
                td { color: #F8FAFC !important; }
                .tag-yes { color: #10B981 !important; font-weight: 800; }
                .tag-no { color: #F43F5E !important; font-weight: 800; }
                .footer { margin-top: 24px; font-size: 11px; color: #64748B; text-align: center; border-top: 1px solid #334155; padding-top: 12px; }
            </style>
        </head>
        <body style="background-color: #0F172A; color: #F8FAFC;">
            <div class="card" style="background-color: #1E293B;">
                <div class="header">
                    <div class="logo">AUTISCREEN</div>
                    <div class="sub">Official Clinical Autism Evaluation Report</div>
                </div>

                <div class="info-box" style="background-color: #0F172A;">
                    <div class="info-line"><span class="info-label">Patient ID:</span> <span class="info-val">#\(patientID)</span></div>
                    \(patientName != nil ? "<div class='info-line'><span class='info-label'>Patient Name:</span> <span class='info-val'>\(patientName!)</span></div>" : "")
                    <div class="info-line"><span class="info-label">Date Evaluated:</span> <span class="info-val">\(details.created_at)</span></div>
                    <div class="info-line" style="margin-top: 10px;"><span class="info-label">Result:</span> <span class="badge">\(details.result_message)</span></div>
                </div>

                <div class="section-title">Symptom Assessment Responses</div>
                <table>
                    <thead>
                        <tr><th>Symptom Indicator</th><th>Response</th></tr>
                    </thead>
                    <tbody>
                    \(details.responses.map { resp in
                        let label = resp.symptom_display_name ?? resp.symptom_name
                        let isYes = resp.response.lowercased() == "yes"
                        let tagClass = isYes ? "tag-yes" : "tag-no"
                        return "<tr><td>\(label)</td><td><span class='\(tagClass)'>\(resp.response.uppercased())</span></td></tr>"
                    }.joined())
                    </tbody>
                </table>

                <div class="footer">Generated via Saveetha Autism Care Network</div>
            </div>
        </body>
        </html>
        """
        
        let fmt = UIMarkupTextPrintFormatter(markupText: htmlContent)
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // A4 Paper Size
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            
            // Fill background with dark navy color (#0F172A) so PDF page is never white
            if let ctx = UIGraphicsGetCurrentContext() {
                ctx.setFillColor(CGColor(red: 15/255.0, green: 23/255.0, blue: 42/255.0, alpha: 1.0))
                ctx.fill(page)
            }
            
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        
        let safeDate = details.created_at.replacingOccurrences(of: ":", with: "-").replacingOccurrences(of: " ", with: "_")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Clinical_Report_\(patientID)_\(safeDate).pdf")
        do {
            try pdfData.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
    
    private var reportText: String {
        guard let details = details else { return "" }
        let nameString = patientName != nil ? "\nPatient Name: \(patientName!)" : ""
        var text = "CLINICAL ASSESSMENT REPORT\n--------------------------\nPatient ID: \(patientID)\(nameString)\nAssessment Date: \(details.created_at)\n\nSUMMARY:\n\(details.result_message)\n\nSYMPTOM MARKERS:\n"
        for resp in details.responses {
            let label = resp.symptom_display_name ?? resp.symptom_name
            text += "- \(label): \(resp.response.uppercased())\n"
        }
        text += "\n--------------------------\nGenerated via System\n"
        return text
    }
}

// MARK: - CUSTOM TAB BAR COMPONENT
struct CustomDoctorTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            tabButton(title: "Patients", icon: "person.2.fill", index: 0)
            tabButton(title: "Analytics", icon: "chart.bar.fill", index: 1)
            tabButton(title: "Profile", icon: "person.circle.fill", index: 2)
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color(hex: "E0F2FE").opacity(0.95))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 10)
    }
    
    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold)) // Slightly larger and bold
                
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded)) // Bolder text
            }
            .foregroundColor(selectedTab == index ? Color(hex: "3B82F6") : Color.black) // Pure black for unselected
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedTab == index ? Color(hex: "3B82F6").opacity(0.12) : Color.clear)
            )
        }
    }
}

// Extension to handle dark mode bar
extension View {
    func toolbarColorStyle(_ scheme: ColorScheme) -> some View {
        return self.toolbarColorScheme(scheme, for: .navigationBar)
    }
}
