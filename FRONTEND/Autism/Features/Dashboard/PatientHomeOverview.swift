import SwiftUI

struct PatientHomeOverview: View {
    @Binding var isPresented: Bool
    let patientID: String
    @EnvironmentObject var languageManager: LanguageManager

    @State private var assessmentCount: Int  = 0
    @State private var reportCount: Int      = 0
    @State private var latestFeedback: String = "No feedback yet."
    @State private var isLoading             = true
    @State private var navigateToAssessment  = false
    @State private var patientName: String   = ""
    @State private var profileImage: String?  = nil

    // entrance animation
    @State private var showContent  = false
    @State private var orbPulse     = false
    @State private var pulse        = false   // for CTA card

    var body: some View {
        StandardBackground {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // ── Greeting header ───────────────────────────────────
                    greetingHeader

                    // ── Stats row ─────────────────────────────────────────
                    HStack(spacing: 14) {
                        statCard(
                            value: "\(assessmentCount)",
                            label: "assessments".localizedPatient(),
                            icon: "waveform.path.ecg",
                            gradient: [Color(red: 0.2, green: 0.6, blue: 1.0), // Vivid Sky
                                       Color(red: 0.0, green: 0.4, blue: 0.8)]  // Deep Azure
                        )
                        statCard(
                            value: "\(reportCount)",
                            label: "feedbacks".localizedPatient(),
                            icon: "bubble.left.and.bubble.right.fill",
                            gradient: [Color(red: 0.1, green: 0.75, blue: 1.0), // Electric Cyan
                                       Color(red: 0.0, green: 0.55, blue: 0.9)] // Sea Blue
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    // ── Progress tile ─────────────────────────────────────
                    progressTile
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    // ── Latest doctor feedback ────────────────────────────
                    feedbackCard
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    // ── CTA: New Assessment ───────────────────────────────
                    newAssessmentCTA
                        .padding(.horizontal, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Color.clear.frame(height: 20)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToAssessment) {
            BehaviourAnalysisView()
                .environmentObject(LanguageManager.shared)
        }
        .onAppear {
            loadPatientName()
            fetchCounts()
            orbPulse = true
            withAnimation(.easeOut(duration: 0.7).delay(0.15)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.5)) {
                pulse = true
            }
        }
    }

    // MARK: - Sub-views ────────────────────────────────────────────────────

    private var greetingHeader: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(Color.orange)
                        .font(.system(size: 14, weight: .black))
                    Text(greetingTime.localizedPatient().uppercased())
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.45)) // High contrast slate mono
                        .tracking(1.5)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\("hello".localizedPatient()), \(patientName.isEmpty ? "..." : patientName)!")
                        .font(.system(size: 30, weight: .black, design: .rounded)) // Max boldness and bigger size
                        .animation(nil, value: patientName) // Prevent 'dancing' on load
                        .foregroundStyle(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1) // Added subtle shadow for depth
                        
                    Text("child_progress_summary".localizedPatient())
                        .font(.system(size: 15, weight: .heavy, design: .rounded)) // Bolder and distinct
                        .foregroundColor(Color(red: 0.05, green: 0.2, blue: 0.4)) // Very dark navy/slate
                }
            }
            .padding(.leading, 4)
            .padding(.vertical, 10)

            Spacer()
        }
        .padding(.horizontal, 20)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : -16)
    }

    @State private var showingJourneyMap = false
    @State private var assessmentHistory: [PatientAssessment] = []

    private var progressTile: some View {
        Button { showingJourneyMap = true } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("monitoring_status".localizedPatient(), systemImage: "chart.xyaxis.line")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3))
                    Spacer()
                    Image(systemName: "hand.tap.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("active".localizedPatient())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .clipShape(Capsule())
                }

                // Progress bar (visual only)
                let ratio: CGFloat = assessmentCount > 0
                    ? min(CGFloat(reportCount) / CGFloat(assessmentCount), 1.0)
                    : 0.0

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("doctor_reviews_complete".localizedPatient())
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color.gray)
                        Spacer()
                        Text("View Roadmap")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.blue)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black.opacity(0.05))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color(red: 0.3, green: 0.8, blue: 1.0)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * (showContent ? ratio : 0), height: 8)
                                .animation(.easeOut(duration: 1.2).delay(0.4), value: showContent)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingJourneyMap) {
            JourneyMapView(history: assessmentHistory)
        }
    }

    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("latest_doctor_feedback".localizedPatient(), systemImage: "stethoscope")
                    .font(.system(size: 14, weight: .black, design: .rounded)) // Increased size and max weight
                    .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                Spacer()
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.cyan.opacity(0.5))
                    .font(.system(size: 16))
            }

            // Feedback quote
            HStack(alignment: .top, spacing: 12) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, Color(red: 0.3, green: 0.5, blue: 1.0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 3)
                    .clipShape(Capsule())

                Text(latestFeedback)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .italic()
                    .foregroundColor(Color.black.opacity(0.8))
                    .lineSpacing(4)
                    .lineLimit(4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
        )
    }

    private var newAssessmentCTA: some View {
        Button { navigateToAssessment = true } label: {
            ZStack {
                // Glow layer
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.2, green: 0.6, blue: 1.0),
                                     Color(red: 0.0, green: 0.4, blue: 0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: pulse ? 14 : 10)
                    .opacity(0.45)
                    .scaleEffect(pulse ? 1.02 : 0.98)

                // Card
                HStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 52, height: 52)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("new_assessment".localizedPatient())
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("start_assessment_subtitle".localizedPatient())
                            .font(.system(size: 12.5, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.4, green: 0.7, blue: 1.0),
                                         Color(red: 0.1, green: 0.4, blue: 0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )
                .shadow(color: Color.cyan.opacity(0.5), radius: 18, x: 0, y: 8)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers ──────────────────────────────────────────────────────

    private var greetingTime: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "good_morning"
        case 12..<17: return "good_afternoon"
        case 17..<21: return "good_evening"
        default:      return "good_night"
        }
    }

    private func statCard(value: String, label: String, icon: String, gradient: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: gradient.first!.opacity(0.5), radius: 8)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                if isLoading {
                    Text("00")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color.gray.opacity(0.3))
                        .redacted(reason: .placeholder)
                } else {
                    Text(value)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(
                            LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)
                        )
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
        )
    }

    private func loadPatientName() {
        patientName = UserDefaults.standard.string(forKey: "current_patient_name") ?? ""
    }

    private func fetchCounts() {
        guard let pid = UserDefaults.standard.string(forKey: "current_patient_id") else {
            isLoading = false
            return
        }

        // Fetch Profile for image
        NetworkManager.shared.getPatientProfile(patientID: pid) { result in
            if case .success(let response) = result {
                if let profile = response.data {
                    self.profileImage = profile.profile_image
                }
            }
        }

        NetworkManager.shared.getPatientAssessments(patientID: pid) { result in
            isLoading = false
            if case .success(let assessments) = result {
                self.assessmentCount = assessments.count
                self.reportCount     = assessments.filter { $0.has_feedback == 1 }.count
                self.assessmentHistory = assessments
            }
        }

        NetworkManager.shared.getAdvice(patientID: pid) { result in
            if case .success(let advice) = result, let last = advice.first {
                self.latestFeedback = last.advice_text
            }
        }
    }

    private func signOut() {
        UserDefaults.standard.removeObject(forKey: "current_patient_id")
        UserDefaults.standard.removeObject(forKey: "current_patient_name")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: NavigationStack {
                RoleSelectionView()
            })
            window.makeKeyAndVisible()
        }
    }
}

#Preview {
    NavigationStack {
        PatientHomeOverview(isPresented: .constant(true), patientID: "1")
    }
}
