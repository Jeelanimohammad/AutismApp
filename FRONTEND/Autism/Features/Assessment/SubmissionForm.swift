import SwiftUI

struct SubmissionForm: View {
    
    @State private var goHome = false
    @State private var goResult = false
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        StandardBackground {
            VStack {
                Spacer()

                // 📦 Card
                VStack(spacing: 20) {

                    // ✅ Success Icon
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 100, height: 100)

                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    // 📝 Title
                    Text("responses_saved".localizedPatient())
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)

                    // 📄 Subtitle
                    Text("assessment_submitted_view".localizedPatient())
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // 🔘 Buttons
                    VStack(spacing: 12) {

                        // ✅ VIEW RESULT
                        Button(action: {
                            goResult = true
                        }) {
                            Text("view_result".localizedPatient())
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }

                        // ✅ BACK TO HOME
                        Button(action: {
                            goHome = true
                        }) {
                            Text("back_to_home".localizedPatient())
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.blue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.blue.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.blue.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        
        // ✅ NAVIGATION → RESULT SCREEN
        .navigationDestination(isPresented: $goResult) {
            AssessmentResultView(isTestCompleted: true)   // 👈 your existing result screen
        }
        
        // ✅ NAVIGATION → ROLE SELECTION
        .navigationDestination(isPresented: $goHome) {
            RoleSelectionView()
        }
    }
}

#Preview {
    NavigationStack {
        SubmissionForm()
    }
}
