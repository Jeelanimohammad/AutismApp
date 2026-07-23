import SwiftUI

struct BehaviourAnalysisView: View {
    @State private var begin = false
    @Environment(\.dismiss) var dismiss
    
    // Animations
    @State private var showContent = false
    @State private var orbPulse = false
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        StandardBackground {
            VStack {
                Spacer()

                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color.black.opacity(0.04), lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .padding(.top, 10)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .opacity(showContent ? 1 : 0)

                    VStack(spacing: 12) {
                        Text("behaviour_analysis".localizedPatient())
                            .font(.system(size: 32, weight: .black, design: .rounded)) // Max boldness and bigger size
                            .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                            .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1) // subtle drop shadow
                            
                        Text("analysis_description".localizedPatient())
                            .font(.system(size: 15, weight: .heavy, design: .rounded)) // Bolder
                            .foregroundColor(Color(red: 0.05, green: 0.2, blue: 0.4)) // Darker navy/slate
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 10)

                    Button {
                        begin = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.0, green: 0.78, blue: 0.88), Color(red: 0.1, green: 0.5, blue: 1.0)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color(red: 0.0, green: 0.78, blue: 0.88).opacity(0.4), radius: 15, x: 0, y: 8)

                            HStack(spacing: 10) {
                                Text("begin_analysis".localizedPatient())
                                    .font(.system(size: 15, weight: .black, design: .rounded)) // Max bold
                                    .tracking(1.2)
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 18))
                            }
                            .foregroundColor(.white)
                        }
                        .frame(height: 60)
                    }
                    .padding(.top, 10)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                }
                .padding(30)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
                        .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)
                }
            }
        }
        .onAppear {
            orbPulse = true
            withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                showContent = true
            }
        }
        .navigationDestination(isPresented: $begin) {
            AgeConfiguration()
                .environmentObject(LanguageManager.shared)
        }
    }
}

#Preview {
    NavigationStack {
        BehaviourAnalysisView()
    }
}
