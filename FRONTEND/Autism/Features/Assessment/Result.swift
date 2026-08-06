import SwiftUI

//////////////////////////////////////////////////////////////
// MARK: - RESULT SCREEN (MATCHES WEB APP DESIGN)
//////////////////////////////////////////////////////////////

struct AssessmentResultView: View {
    @State private var goHome = false
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    var isTestCompleted: Bool = false
    var resultMessage: String? = nil
    var yesCount: Int = 0
    var totalCount: Int = 0
    
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Banner Header
                VStack(spacing: 6) {
                    Text("assessment_result_title".localizedPatient())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("review_analysis_below".localizedPatient())
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
                
                if isTestCompleted {
                    // White Main Analysis Card
                    VStack(spacing: 20) {
                        Capsule()
                            .fill(Color(red: 0.1, green: 0.5, blue: 1.0))
                            .frame(width: 50, height: 4)
                            .padding(.top, 8)
                        
                        // 1. Clinical Result Section
                        VStack(spacing: 10) {
                            Text("clinical_result_label".localizedPatient())
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
                            Text("ai_summary_label".localizedPatient())
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.85))
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Text("•").foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.88)).bold()
                                    Text("\("screening_score_label".localizedPatient()): \(yesCount) / \(totalCount)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.black.opacity(0.85))
                                }
                                
                                HStack(spacing: 8) {
                                    Text("•").foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.88)).bold()
                                    Text("\("indicators_detected_label".localizedPatient()): \(yesCount)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.black.opacity(0.85))
                                }
                                
                                HStack(spacing: 8) {
                                    Text("•").foregroundColor(Color(red: 0.0, green: 0.78, blue: 0.88)).bold()
                                    HStack(spacing: 4) {
                                        Text("\("risk_level_label".localizedPatient()): ")
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
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(Color(red: 0.1, green: 0.5, blue: 1.0).opacity(0.6))
                        
                        Text("no_results_available".localizedPatient())
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(Color.black.opacity(0.85))
                        
                        Text("complete_assessment_view".localizedPatient())
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    .padding(.horizontal, 20)
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("close".localizedPatient())
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
        .background(Color(hex: "F8FAFF").ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        AssessmentResultView(isTestCompleted: true, resultMessage: "Your child needs further Diagnostic Tests for Autism.", yesCount: 6, totalCount: 7)
    }
}
