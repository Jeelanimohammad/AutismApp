import SwiftUI

struct PatientPortal: View {

    // entrance animations
    @State private var headerReady  = false
    @State private var card1Ready   = false
    @State private var card2Ready   = false
    @State private var orbPulse     = false
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        StandardBackground {
            // ── Main content ───────────────────────────────────────────────
            VStack(spacing: 0) {
                
                // ── Hero header ───────────────────────────────────────────
                VStack(spacing: 14) {
                    // Icon badge
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.35), .orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .shadow(color: Color.orange.opacity(0.4), radius: 20)

                        Image("Image")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    }
                    .scaleEffect(headerReady ? 1 : 0.4)
                    .opacity(headerReady ? 1 : 0)

                    VStack(spacing: 6) {
                        Text("patient_portal".localizedPatient())
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy

                        Text("child_journey_starts".localizedPatient())
                            .font(.system(size: 14, weight: .bold, design: .rounded)) // Bolder
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4)) // Darker slate
                            .multilineTextAlignment(.center)
                    }
                    .opacity(headerReady ? 1 : 0)
                    .offset(y: headerReady ? 0 : 12)
                }
                .padding(.top, 36)
                .padding(.horizontal, 28)

                // ── Marquee ticker ────────────────────────────────────────
                PortalMarquee(text: "✦  Guiding Your Child's Care  ✦  Early Detection, Better Outcomes  ✦  Compassionate Clinical Support  ✦")
                    .frame(height: 32)
                    .padding(.top, 14)

                // ── Action cards ──────────────────────────────────────────
                VStack(spacing: 16) {
                    // Continue as Patient
                    NavigationLink(destination: PatientLoginView().environmentObject(LanguageManager.shared)) {
                        PremiumPortalCard(
                            icon: "person.2.fill",
                            iconColor: .orange,
                            title: "continue_as_patient".localizedPatient(),
                            subtitle: "access_profile_history".localizedPatient(),
                            accentGradient: [.orange, Color(red: 1.0, green: 0.5, blue: 0.0)]
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: card1Ready ? 0 : -60)
                    .opacity(card1Ready ? 1 : 0)

                    // Register as Patient
                    NavigationLink(destination: PatientDetailsView().environmentObject(LanguageManager.shared)) {
                        PremiumPortalCard(
                            icon: "person.crop.circle.badge.plus",
                            iconColor: .orange,
                            title: "register_as_patient".localizedPatient(),
                            subtitle: "create_new_profile_subtitle".localizedPatient(),
                            accentGradient: [.orange, Color(red: 0.9, green: 0.4, blue: 0.1)]
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: card2Ready ? 0 : 60)
                    .opacity(card2Ready ? 1 : 0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 48)
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

// MARK: - Premium Portal Card
struct PremiumPortalCard: View {
    let icon: String
    let iconColor: Color
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
                    .shadow(color: accentGradient.first!.opacity(0.55), radius: 12, x: 0, y: 6)

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
                    .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5)) // Darker Slate
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

// MARK: - Marquee Ticker
struct PortalMarquee: View {
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
                        offset = -800
                    }
                }
        }
        .clipped()
        .overlay(
            HStack {
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.97, blue: 1.0), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 30)
                Spacer()
                LinearGradient(
                    colors: [.clear, Color(red: 0.85, green: 0.92, blue: 0.98)],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: 30)
            }
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack { PatientPortal() }
}
