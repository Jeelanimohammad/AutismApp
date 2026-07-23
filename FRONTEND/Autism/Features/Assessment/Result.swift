import SwiftUI

//////////////////////////////////////////////////////////////
// MARK: - RESULT SCREEN
//////////////////////////////////////////////////////////////

struct AssessmentResultView: View {
    
    @State private var goHome = false
    @EnvironmentObject var languageManager: LanguageManager
    
    // ✅ CONTROL THIS (set true after test completion)
    var isTestCompleted: Bool = false
    
    var body: some View {
        StandardBackground {
            VStack(spacing: 20) {
                
                // 🔷 HEADER
                VStack(spacing: 6) {
                    Text("assessment_result_title".localizedPatient())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("review_analysis_below".localizedPatient())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                
                Spacer()
                
                // 📦 CARD
                VStack(spacing: 20) {
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.blue)
                        .frame(width: 50, height: 4)
                    
                    // ❗ SHOW ONLY AFTER TEST
                    if isTestCompleted {
                        
                        // 🧾 Clinical Result
                        VStack(spacing: 10) {
                            Text("clinical_result_label".localizedPatient())
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("Your child may require further diagnostic evaluation.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.green.opacity(0.15))
                                .cornerRadius(10)
                        }
                        
                        // 🤖 AI Summary
                        VStack(spacing: 10) {
                            Text("ai_summary_label".localizedPatient())
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• \("screening_score_label".localizedPatient()): 6 / 7")
                                Text("• \("indicators_detected_label".localizedPatient()): 6")
                                Text("• \("risk_level_label".localizedPatient()): High")
                                
                                Text("The pattern suggests strong behavioral indicators. Professional consultation is recommended.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                    } else {
                        
                        // 🚫 BEFORE TEST MESSAGE
                        VStack(spacing: 10) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            Text("no_results_available".localizedPatient())
                                .font(.headline)
                            
                            Text("complete_assessment_view".localizedPatient())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 8)
                .padding(.horizontal)
                
                Spacer()
                
                // 🔘 CLOSE BUTTON
                Button {
                    goHome = true
                } label: {
                    Text("close".localizedPatient())
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
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 10)
            }
        }
        
        // ✅ NAVIGATION
        .navigationDestination(isPresented: $goHome) {
            GetStarted()
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - GET STARTED SCREEN
//////////////////////////////////////////////////////////////

struct GetStartedView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            Text("Get Started Screen")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - PREVIEW
//////////////////////////////////////////////////////////////

#Preview {
    NavigationStack {
        AssessmentResultView(isTestCompleted: false) // ❌ before test
    }
}

#Preview("After Test") {
    NavigationStack {
        AssessmentResultView(isTestCompleted: true) // ✅ after test
    }
}
