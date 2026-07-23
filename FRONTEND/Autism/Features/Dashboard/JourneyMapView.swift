import SwiftUI

struct JourneyMapView: View {
    let history: [PatientAssessment]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(hex: "F8FAFC"), Color(hex: "F1F5F9")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("Developmental Journey")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding()
                
                if history.isEmpty {
                    ContentUnavailableView("No Data Yet", systemImage: "map", description: Text("Complete your first assessment to start your journey."))
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack {
                            // The Path
                            JourneyPath(count: history.count)
                                .stroke(
                                    LinearGradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.3)], startPoint: .top, endPoint: .bottom),
                                    style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [10, 10])
                                )
                            
                            // The Milestones
                            VStack(spacing: 0) {
                                ForEach(Array(history.enumerated()), id: \.element.id) { index, assessment in
                                    MilestoneNode(index: index, assessment: assessment)
                                        .offset(x: index % 2 == 0 ? 50 : -50)
                                        .padding(.vertical, 40)
                                }
                            }
                        }
                        .padding(.vertical, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct JourneyPath: Shape {
    let count: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard count > 0 else { return path }
        
        let startX = rect.midX
        path.move(to: CGPoint(x: startX, y: 0))
        
        let segmentHeight: CGFloat = 120 // Approximation adjust based on Node padding
        
        for i in 0..<count {
            let y = CGFloat(i) * segmentHeight + 100
            let xOffset: CGFloat = i % 2 == 0 ? 50 : -50
            let controlY = y - segmentHeight/2
            
            path.addQuadCurve(to: CGPoint(x: rect.midX + xOffset, y: y),
                              control: CGPoint(x: rect.midX, y: controlY))
        }
        
        return path
    }
}

struct MilestoneNode: View {
    let index: Int
    let assessment: PatientAssessment
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                
                Circle()
                    .stroke(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Text("\(index + 1)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .center, spacing: 4) {
                Text(assessment.created_at.prefix(10))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                
                Text(assessment.result_message.replacingOccurrences(of: "assessment", with: "").localizedPatient())
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
            }
        }
    }
}
