import SwiftUI

struct SeverityInfo {
    let color: Color
    let light: Color
    let border: Color
    let label: String
    let iconName: String
}

func getSeverityInfo(_ resultMessage: String) -> SeverityInfo {
    let msg = resultMessage.lowercased()
    if msg.contains("high") || msg.contains("severe") || msg.contains("critical") {
        return SeverityInfo(
            color: Color(hex: "DC2626"),
            light: Color(hex: "FEF2F2"),
            border: Color(hex: "FECACA"),
            label: "High Risk",
            iconName: "exclamationmark.circle.fill"
        )
    }
    if msg.contains("moderate") || msg.contains("medium") {
        return SeverityInfo(
            color: Color(hex: "EA580C"),
            light: Color(hex: "FFF7ED"),
            border: Color(hex: "FED7AA"),
            label: "Moderate",
            iconName: "exclamationmark.triangle.fill"
        )
    }
    if msg.contains("low") || msg.contains("minimal") || msg.contains("no risk") {
        return SeverityInfo(
            color: Color(hex: "16A34A"),
            light: Color(hex: "F0FDF4"),
            border: Color(hex: "BBF7D0"),
            label: "Low Risk",
            iconName: "checkmark.circle.fill"
        )
    }
    return SeverityInfo(
        color: Color(hex: "2563EB"),
        light: Color(hex: "EFF6FF"),
        border: Color(hex: "BFDBFE"),
        label: "Assessed",
        iconName: "star.fill"
    )
}

struct JourneyMapView: View {
    let history: [PatientAssessment]
    @Environment(\.dismiss) var dismiss
    
    var sortedHistory: [PatientAssessment] {
        history.sorted { $0.created_at < $1.created_at }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8FAFF").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ── HEADER ──
                VStack(spacing: 16) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 46, height: 46)
                            
                            Image(systemName: "map.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Developmental Journey")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("\(sortedHistory.count) milestone\(sortedHistory.count != 1 ? "s" : "") recorded")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    
                    // Journey Progress Bar
                    if !sortedHistory.isEmpty {
                        VStack(spacing: 6) {
                            HStack {
                                Text("JOURNEY PROGRESS")
                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                    .tracking(1)
                                Spacer()
                                Text("\(sortedHistory.count) Complete")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                                .frame(height: 6)
                                .overlay(
                                    GeometryReader { geo in
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: geo.size.width)
                                    },
                                    alignment: .leading
                                )
                        }
                    }
                }
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "1D4ED8"), Color(hex: "16A34A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // ── BODY ──
                if sortedHistory.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(hex: "EEF2FF"))
                                .frame(width: 80, height: 80)
                            Image(systemName: "flag.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Color(hex: "2563EB"))
                        }
                        Text("No Milestones Yet")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "1E293B"))
                        Text("Complete your first assessment to begin the journey.")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "64748B"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack(alignment: .leading) {
                            // Timeline Spine
                            LinearGradient(
                                colors: [Color(hex: "1D4ED8"), Color(hex: "16A34A"), Color(hex: "EA580C")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: 3)
                            .cornerRadius(1.5)
                            .opacity(0.3)
                            .offset(x: 27)
                            .padding(.vertical, 28)
                            
                            // Milestone List
                            VStack(spacing: 20) {
                                ForEach(Array(sortedHistory.enumerated()), id: \.element.id) { index, assessment in
                                    let isLast = index == sortedHistory.count - 1
                                    let severity = getSeverityInfo(assessment.result_message)
                                    
                                    HStack(alignment: .top, spacing: 16) {
                                        // Node Icon
                                        ZStack {
                                            if isLast {
                                                Circle()
                                                    .stroke(severity.color.opacity(0.4), lineWidth: 2)
                                                    .frame(width: 66, height: 66)
                                            }
                                            
                                            Circle()
                                                .fill(severity.light)
                                                .frame(width: 54, height: 54)
                                                .overlay(Circle().stroke(severity.border, lineWidth: 2.5))
                                                .shadow(color: severity.color.opacity(0.2), radius: 6, y: 3)
                                            
                                            Image(systemName: severity.iconName)
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(severity.color)
                                        }
                                        .frame(width: 56)
                                        
                                        // Card
                                        VStack(alignment: .leading, spacing: 10) {
                                            // Top Row (Step Badge, Latest Tag, Date)
                                            HStack {
                                                Text("STEP \(index + 1)")
                                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(severity.color)
                                                    .clipShape(Capsule())
                                                
                                                if isLast {
                                                    HStack(spacing: 4) {
                                                        Circle().fill(Color(hex: "16A34A")).frame(width: 6, height: 6)
                                                        Text("Latest")
                                                            .font(.system(size: 10, weight: .black, design: .rounded))
                                                            .foregroundColor(Color(hex: "16A34A"))
                                                    }
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(Color(hex: "DCFCE7"))
                                                    .cornerRadius(10)
                                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "BBF7D0"), lineWidth: 1))
                                                }
                                                
                                                Spacer()
                                                
                                                Text(String(assessment.created_at.prefix(10)))
                                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                    .foregroundColor(Color(hex: "94A3B8"))
                                            }
                                            
                                            // Result Message
                                            Text(assessment.result_message)
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "0F172A"))
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            // Bottom Row (Risk Label, Time)
                                            HStack {
                                                HStack(spacing: 6) {
                                                    Circle()
                                                        .fill(severity.color)
                                                        .frame(width: 8, height: 8)
                                                    Text(severity.label)
                                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                                        .foregroundColor(severity.color)
                                                }
                                                
                                                Spacer()
                                                
                                                if assessment.created_at.count >= 16 {
                                                    Text(String(assessment.created_at.suffix(8).prefix(5)))
                                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                        .foregroundColor(Color(hex: "94A3B8"))
                                                }
                                            }
                                        }
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(18)
                                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(severity.border, lineWidth: 1.5))
                                        .shadow(color: severity.color.opacity(0.08), radius: 10, x: 0, y: 4)
                                    }
                                }
                                
                                // Finish Flag Row
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "E2E8F0"))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "flag.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "94A3B8"))
                                    }
                                    .frame(width: 56)
                                    
                                    Text("Your journey continues…")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .italic()
                                        .foregroundColor(Color(hex: "94A3B8"))
                                    
                                    Spacer()
                                }
                                .padding(.top, 6)
                                .opacity(0.7)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
