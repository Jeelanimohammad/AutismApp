import SwiftUI

struct RoleSelectionView: View {
    @State private var parent = false
    @State private var doctor = false
    
    // Animations
    @State private var showContent = false
    @State private var orbPulse = false
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        StandardBackground {
            // ── Main Content ───────────────────────────────────────────────
            VStack(spacing: 24) {
                
                // MARK: App Branding
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.cyan.opacity(0.5), radius: 25, x: 0, y: 0) // Neon glow
                        
                        Image("Welcome")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 76, height: 76)
                            .clipShape(Circle())
                    }
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                    
                    VStack(spacing: 6) {
                        Text("Saveetha Autism Care")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy for sharp clarity
                            
                        Text("Precision Diagnostics & Clinical Monitoring")
                            .font(.system(size: 14, weight: .bold, design: .rounded)) // Bolder and blacker
                            .foregroundColor(Color(red: 0.05, green: 0.2, blue: 0.5)) // High contrast blue
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 10)
                }
                .padding(.top, 40)
                
                Text("select_portal".localizedPatient())
                    .font(.system(size: 14, weight: .black, design: .rounded)) // Solid and visible
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.35)) // Defined backdrop for label
                    .cornerRadius(12)
                    .tracking(2)
                    .opacity(showContent ? 1 : 0)

                // MARK: Selection Cards
                VStack(spacing: 20) {
                    
                    RoleCard(
                        title: "patient_portal".localizedPatient(),
                        subtitle: "patient_portal_subtitle".localizedPatient(),
                        icon: "figure.and.child.holdinghands",
                        accentColor: .orange, // Warm amber for caring approach
                        action: { parent = true }
                    )
                    .offset(x: showContent ? 0 : -50)
                    .opacity(showContent ? 1 : 0)
                    
                    RoleCard(
                        title: "doctor_portal".localizedPatient(),
                        subtitle: "doctor_portal_subtitle".localizedPatient(),
                        icon: "stethoscope",
                        accentColor: .green, // Professional emerald for clinical excellence
                        action: { doctor = true }
                    )
                    .offset(x: showContent ? 0 : 50)
                    .opacity(showContent ? 1 : 0)
                    
                }
                .padding(.horizontal, 24)
                
                // Footer
                Text("trusted_medical".localizedPatient())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Solid visibility
                    .padding(.top, 12)
                    .opacity(showContent ? 1 : 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $parent) {
            PatientPortal()
                .environmentObject(LanguageManager.shared)
        }
        .navigationDestination(isPresented: $doctor) {
            DoctorPortal()
                .environmentObject(LanguageManager.shared)
        }
        .onAppear {
            orbPulse = true
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

// MARK: - Premium Role Card
struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(accentColor.opacity(0.4), lineWidth: 1.5)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(accentColor)
                        .shadow(color: accentColor.opacity(0.6), radius: 6, x: 0, y: 0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy for crystal clear readability
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(accentColor.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white)
                    .shadow(color: Color.blue.opacity(0.08), radius: 15, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.blue.opacity(0.05), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        RoleSelectionView()
    }
}
