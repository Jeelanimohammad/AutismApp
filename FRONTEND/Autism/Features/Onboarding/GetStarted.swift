import SwiftUI

// MARK: - Particle model
private struct Particle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
}

// MARK: - Premium GetStarted
struct GetStarted: View {

    // --- Phase 1: 3D Flip & Zoom ---
    @State private var logoDotScale: CGFloat   = 0.0
    @State private var logoRotation: Double    = -120
    @State private var logoDotOpacity: Double  = 0.0

    // --- Phase 2: Core Glow ---
    @State private var burstScale: CGFloat     = 0.0
    @State private var burstOpacity: Double    = 0.0

    // --- Phase 3: Mesmerizing Rings ---
    @State private var ringScale: CGFloat      = 0.2
    @State private var ringOpacity: Double     = 0.0
    @State private var pulse: Bool             = false
    @State private var ringRotation: Double    = 0

    // --- Phase 4: Swirling Particles ---
    @State private var particlesVisible: Bool  = false

    // --- Phase 5: Typography ---
    @State private var textOpacity: Double     = 0.0
    @State private var textOffset: CGFloat     = 40
    @State private var shimmerOffset: CGFloat  = -1.0 // for the text shimmer map

    // --- Phase 6: Exit Zoom ---
    @State private var exitScale: CGFloat      = 1.0
    @State private var exitOpacity: Double     = 1.0
    
    // --- Phase 0: Ambient Background Orbs ---
    @State private var ambientPulse: Bool      = false

    @State private var navigate = false

    private let particles: [Particle] = {
        var list: [Particle] = []
        let count = 40
        for i in 0..<count {
            let angle = (Double(i) / Double(count)) * Double.pi * 2
            let dist  = CGFloat.random(in: 120...240)
            let sz    = CGFloat.random(in: 2...6)
            let dur   = Double.random(in: 1.0...1.8)
            let delay = Double.random(in: 0.0...0.4)
            list.append(Particle(angle: angle, distance: dist, size: sz, duration: dur, delay: delay))
        }
        return list
    }()

    var body: some View {
        StandardBackground {
            // ─── Core Interaction Layer ─────────────────────────────────────────
            ZStack {
                // 1. Core Burst
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.15),
                                Color.cyan.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .scaleEffect(burstScale)
                    .opacity(burstOpacity)
                    .blur(radius: 20)

                // 2. Holographic Scanning Rings
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.clear,
                                    Color.blue.opacity(0.9),
                                    Color.indigo,
                                    Color.cyan.opacity(0.9),
                                    Color.clear
                                ],
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            lineWidth: 3 // Made thicker for visibility on light background
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(ringRotation))

                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                        .frame(width: 260, height: 260)
                        .scaleEffect(pulse ? 1.05 : 0.95)
                        .opacity(ringOpacity * 0.8)
                }
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

                // 3. Swirling Orbiting Particles
                ForEach(particles) { p in
                    Circle()
                        .fill(particleColor(for: p))
                        .frame(width: p.size, height: p.size)
                        .offset(
                            x: particlesVisible ? cos(p.angle + ringRotation * 0.02) * p.distance : 0,
                            y: particlesVisible ? sin(p.angle + ringRotation * 0.02) * p.distance : 0
                        )
                        .opacity(particlesVisible ? Double.random(in: 0.7...1.0) : 0)
                        .animation(
                            .easeOut(duration: p.duration).delay(p.delay),
                            value: particlesVisible
                        )
                        .shadow(color: .black.opacity(0.1), radius: 2) // Switched to dark shadow for contrast
                }

                // 4. Logo with 3D Flip
                ZStack {
                    Circle()
                        .fill(Color.white) // Solid white to pop against the blue background
                        .frame(width: 170, height: 170)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10) // Strong drop shadow

                    Image("Welcome")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.6), .clear, .indigo.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                }
                .scaleEffect(logoDotScale)
                .opacity(logoDotOpacity)
                .rotation3DEffect(.degrees(logoRotation), axis: (x: 0, y: 1, z: 0))
            }

            // ─── Premium Typography ─────────────────────────────────────────
            VStack {
                Spacer()

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: 25, height: 1.5)
                        Text("CLINICAL EVALUATION")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                            .tracking(5)
                        Rectangle()
                            .fill(Color.blue.opacity(0.8))
                            .frame(width: 25, height: 1.5)
                    }

                    // Shimmering Text Mask
                    Text("Autism Assessment")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(
                                colors: [.blue, .indigo, .cyan, .indigo, .blue],
                                startPoint: UnitPoint(x: shimmerOffset, y: 0),
                                endPoint: UnitPoint(x: shimmerOffset + 1.0, y: 0)
                            )
                            .mask(
                                Text("Autism Assessment")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                            )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)

                    Text("Early detection. Better outcomes.")
                        .font(.system(size: 15, weight: .bold, design: .rounded)) // Made bold for visibility
                        .foregroundColor(Color(red: 0.35, green: 0.40, blue: 0.50)) // High contrast dark slate
                        .tracking(0.5)
                        .padding(.top, 2)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
                .padding(.bottom, 80)
            }
        }
        .scaleEffect(exitScale)
        .opacity(exitOpacity)
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear(perform: runSequence)
        .navigationDestination(isPresented: $navigate) {
            RoleSelectionView()
                .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Animation Engine
    private func runSequence() {
        let impact = UIImpactFeedbackGenerator(style: .rigid)
        impact.prepare()

        ambientPulse = true

        withAnimation(.interpolatingSpring(stiffness: 80, damping: 10)) {
            logoDotScale = 1.0
            logoRotation = 0
            logoDotOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            impact.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.8)) {
                burstScale = 1.0
                burstOpacity = 1.0
                ringScale = 1.0
                ringOpacity = 1.0
            }
            
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particlesVisible = true
            let softImpact = UIImpactFeedbackGenerator(style: .soft)
            softImpact.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeOut(duration: 0.7)) {
                textOpacity = 1.0
                textOffset = 0
            }
            
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.5
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
            heavyImpact.impactOccurred()
            
            withAnimation(.easeIn(duration: 0.6)) {
                exitScale = 10.0
                exitOpacity = 0.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            navigate = true
        }
    }

    private func particleColor(for p: Particle) -> Color {
        // High visibility bright colors over light background
        let colors: [Color] = [.blue, .indigo, .purple, .cyan, .teal]
        return colors[Int(p.angle * 10) % colors.count]
    }
}

#Preview {
    NavigationStack {
        GetStarted()
    }
}
