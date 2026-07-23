import SwiftUI

struct DoctorPortal: View {
    // entrance animations
    @State private var headerReady  = false
    @State private var card1Ready   = false
    @State private var card2Ready   = false
    @State private var orbPulse     = false

    var body: some View {
        StandardBackground {
            // ── Main content ───────────────────────────────────────────────
            VStack(spacing: 0) {
                
                // ── Hero header ───────────────────────────────────────────
                VStack(spacing: 14) {
                    // Doctor Badge (Premium Illustration)
                    Image("doctor_portal_hero")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.green.opacity(0.4), .green.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .shadow(color: Color.green.opacity(0.2), radius: 15)
                        .scaleEffect(headerReady ? 1 : 0.4)
                        .opacity(headerReady ? 1 : 0)

                    VStack(spacing: 6) {
                        Text("doctor_portal".localizedDoctor())
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy

                        Text("professional_clinical_care".localizedDoctor())
                            .font(.system(size: 14, weight: .bold, design: .rounded)) // Bolder
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4)) // Darker Slate
                            .multilineTextAlignment(.center)
                    }
                    .opacity(headerReady ? 1 : 0)
                    .offset(y: headerReady ? 0 : 12)
                }
                .padding(.top, 40)
                .padding(.horizontal, 28)

                // ── Marquee ticker ────────────────────────────────────────
                DoctorMarquee(text: "empowering_doctors_marquee".localizedDoctor())
                    .frame(height: 32)
                    .padding(.top, 24)

                // ── Action cards ──────────────────────────────────────────
                VStack(spacing: 18) {
                    // Continue as Doctor
                    NavigationLink(destination: DoctorLoginView().environmentObject(LanguageManager.shared)) {
                        PremiumDoctorCard(
                            icon: "cross.case.fill",
                            iconAccent: .green,
                            title: "continue_as_doctor".localizedDoctor(),
                            subtitle: "secure_auth_patient_lists".localizedDoctor(),
                            accentGradient: [.green, Color(red: 0.0, green: 0.6, blue: 0.2)]
                        )
                    }
                    .buttonStyle(.plain)
                    .offset(x: card1Ready ? 0 : -60)
                    .opacity(card1Ready ? 1 : 0)

                    // Register as Doctor
                    NavigationLink(destination: DoctorDetailsView().environmentObject(LanguageManager.shared)) {
                        PremiumDoctorCard(
                            icon: "person.crop.circle.badge.plus",
                            iconAccent: .green,
                            title: "register_as_doctor".localizedDoctor(),
                            subtitle: "join_professional_network".localizedDoctor(),
                            accentGradient: [.green, Color(red: 0.1, green: 0.7, blue: 0.3)]
                        )
                    }
                    .buttonStyle(.plain)
                    .offset(x: card2Ready ? 0 : 60)
                    .opacity(card2Ready ? 1 : 0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            orbPulse = true
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                headerReady = true
            }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.35)) {
                card1Ready = true
            }
            withAnimation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.5)) {
                card2Ready = true
            }
        }
    }
}

// MARK: - Premium Doctor Card
struct PremiumDoctorCard: View {
    let icon: String
    let iconAccent: Color
    let title: String
    let subtitle: String
    let accentGradient: [Color]

    var body: some View {
        HStack(spacing: 18) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: accentGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: accentGradient.first!.opacity(0.4), radius: 10, x: 0, y: 5)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                Text(subtitle)
                    .font(.system(size: 12.5, weight: .bold, design: .rounded)) // Bolder
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4)) // Darker Slate
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.gray.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            }
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Doctor Marquee Ticker
struct DoctorMarquee: View {
    let text: String
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            Text(text)
                .font(.system(size: 12.5, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.gray.opacity(0.9))
                .tracking(1.5)
                .fixedSize()
                .offset(x: offset)
                .onAppear {
                    offset = width
                    withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                        offset = -900
                    }
                }
        }
        .clipped()
        .overlay(
            HStack {
                LinearGradient(
                    colors: [Color(red: 0.85, green: 0.94, blue: 1.0), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 40)
                Spacer()
                LinearGradient(
                    colors: [.clear, Color(red: 0.75, green: 0.90, blue: 0.98)],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 40)
            }
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack { DoctorPortal() }
}
