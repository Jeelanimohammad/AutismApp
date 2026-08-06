import SwiftUI
import Charts

struct AgeBracket: Identifiable {
    let id = UUID()
    let name: String
    let minAge: Int
    let maxAge: Int
    var count: Int
}

struct GenderStat: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let color: Color
}

struct RiskStat: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let color: Color
}

struct DoctorAnalyticsView: View {
    @Binding var selectedTab: Int
    @State private var patients: [Patient] = []
    @State private var isLoading = true
    @EnvironmentObject var languageManager: LanguageManager
    
    var totalPatients: Int { patients.count }
    var withPending: Int { patients.reduce(0) { $0 + max(($1.pending_reviews ?? 0), ($1.has_advice ?? 0) == 0 ? 1 : 0) } }
    var reviewedPatients: Int { patients.filter { ($0.has_advice ?? 0) > 0 && ($0.pending_reviews ?? 0) == 0 }.count }
    var reviewRate: Int { totalPatients > 0 ? Int(round(Double(reviewedPatients) / Double(totalPatients) * 100)) : 0 }
    
    var ageBrackets: [AgeBracket] {
        var brackets = [
            AgeBracket(name: "Under 2", minAge: 0, maxAge: 2, count: 0),
            AgeBracket(name: "2–4 yrs", minAge: 2, maxAge: 4, count: 0),
            AgeBracket(name: "4–6 yrs", minAge: 4, maxAge: 6, count: 0),
            AgeBracket(name: "6–10 yrs", minAge: 6, maxAge: 10, count: 0),
            AgeBracket(name: "10+ yrs", minAge: 10, maxAge: 999, count: 0)
        ]
        for p in patients {
            let age = p.age ?? 0
            if let idx = brackets.firstIndex(where: { age >= $0.minAge && age < $0.maxAge }) {
                brackets[idx].count += 1
            }
        }
        return brackets
    }
    
    var riskStats: [RiskStat] {
        var list: [RiskStat] = []
        let totalPending = patients.reduce(0) { $0 + ($1.pending_reviews ?? 0) }
        let totalReviewed = patients.reduce(0) { $0 + ($1.reviewed_count ?? 0) }
        
        if totalPending > 0 {
            list.append(RiskStat(name: "High Risk", count: totalPending, color: Color(hex: "EF4444")))
        }
        if totalReviewed > 0 {
            list.append(RiskStat(name: "Reviewed", count: totalReviewed, color: Color(hex: "10B981")))
        }
        return list
    }
    
    var genderStats: [GenderStat] {
        let m = patients.filter { $0.sex?.lowercased() == "male" }.count
        let f = patients.filter { $0.sex?.lowercased() == "female" }.count
        let o = patients.filter { p in
            guard let sex = p.sex?.lowercased() else { return true }
            return sex != "male" && sex != "female"
        }.count
        
        var list: [GenderStat] = []
        if m > 0 { list.append(GenderStat(name: "Male", count: m, color: Color(hex: "3B82F6"))) }
        if f > 0 { list.append(GenderStat(name: "Female", count: f, color: Color(hex: "EC4899"))) }
        if o > 0 { list.append(GenderStat(name: "Other", count: o, color: Color(hex: "8B5CF6"))) }
        return list
    }
    
    var body: some View {
        ZStack {
            // Ambient light background
            LinearGradient(
                colors: [Color.white, Color(hex: "F8FAFC"), Color(hex: "F1F5F9")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main Scroll Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // ── HEADER ──
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(Color(hex: "3B82F6"))
                                    .font(.system(size: 14, weight: .bold))
                                Text("CLINICAL ANALYTICS")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "3B82F6"))
                                    .tracking(1.2)
                            }
                            
                            Text("Practice Overview")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "0F172A"))
                            
                            Text("Data-driven insights across your patient panel.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "64748B"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                        
                        if isLoading {
                            ProgressView()
                                .tint(Color(hex: "3B82F6"))
                                .padding(.top, 60)
                        } else {
                            // ── KPI GRID ──
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                AnalyticsKpiCard(
                                    title: "Total Patients",
                                    value: "\(totalPatients)",
                                    icon: "person.3.fill",
                                    color: Color(hex: "3B82F6"),
                                    bgColor: Color(hex: "EFF6FF")
                                )
                                AnalyticsKpiCard(
                                    title: "Pending Reviews",
                                    value: "\(withPending)",
                                    icon: "clock.fill",
                                    color: Color(hex: "F59E0B"),
                                    bgColor: Color(hex: "FFFBEB")
                                )
                                AnalyticsKpiCard(
                                    title: "Fully Reviewed",
                                    value: "\(reviewedPatients)",
                                    icon: "checkmark.circle.fill",
                                    color: Color(hex: "10B981"),
                                    bgColor: Color(hex: "ECFDF5")
                                )
                                AnalyticsKpiCard(
                                    title: "Review Rate",
                                    value: "\(reviewRate)%",
                                    icon: "arrow.up.forward",
                                    color: Color(hex: "8B5CF6"),
                                    bgColor: Color(hex: "F5F3FF")
                                )
                            }
                            .padding(.horizontal, 20)
                            
                            // ── AGE DISTRIBUTION VERTICAL BAR CHART ──
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "waveform.path.ecg")
                                        .foregroundColor(Color(hex: "3B82F6"))
                                    Text("Patient Age Distribution")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "0F172A"))
                                }
                                
                                if totalPatients == 0 {
                                    Text("No data yet")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "94A3B8"))
                                        .frame(maxWidth: .infinity, minHeight: 140)
                                } else {
                                    Chart(ageBrackets) { bracket in
                                        BarMark(
                                            x: .value("Age Group", bracket.name),
                                            y: .value("Patients", bracket.count)
                                        )
                                        .cornerRadius(6)
                                        .foregroundStyle(Color(hex: "3B82F6"))
                                    }
                                    .chartYScale(domain: 0...max(4, (ageBrackets.map(\.count).max() ?? 1) + 1))
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) { value in
                                            AxisValueLabel()
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color(hex: "64748B"))
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(values: .automatic) { value in
                                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                                                .foregroundStyle(Color(hex: "E2E8F0"))
                                            AxisValueLabel()
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(Color(hex: "94A3B8"))
                                        }
                                    }
                                    .frame(height: 180)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                            .padding(.horizontal, 20)
                            
                            // ── REVIEW STATUS DONUT CHART ──
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(Color(hex: "F59E0B"))
                                    Text("Review Status")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "0F172A"))
                                }
                                
                                if totalPatients == 0 {
                                    Text("No data yet")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "94A3B8"))
                                        .frame(maxWidth: .infinity, minHeight: 140)
                                } else {
                                    VStack(spacing: 16) {
                                        Chart(riskStats) { item in
                                            SectorMark(
                                                angle: .value("Count", item.count),
                                                innerRadius: .ratio(0.62),
                                                angularInset: 0.0
                                            )
                                            .foregroundStyle(item.color)
                                        }
                                        .frame(height: 170)
                                        
                                        HStack(spacing: 20) {
                                            ForEach(riskStats) { item in
                                                HStack(spacing: 6) {
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(item.color)
                                                        .frame(width: 14, height: 10)
                                                    Text(item.name)
                                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                                        .foregroundColor(Color(hex: "475569"))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                            .padding(.horizontal, 20)
                            
                            // ── GENDER DISTRIBUTION CARD ──
                            if !genderStats.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "person.2")
                                            .foregroundColor(Color(hex: "8B5CF6"))
                                        Text("Gender Distribution")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: "0F172A"))
                                    }
                                    
                                    HStack(spacing: 12) {
                                        ForEach(genderStats) { g in
                                            let pct = totalPatients > 0 ? Int(round(Double(g.count) / Double(totalPatients) * 100)) : 0
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("\(g.count)")
                                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                                    .foregroundColor(g.color)
                                                Text(g.name)
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .foregroundColor(Color(hex: "64748B"))
                                                
                                                Capsule()
                                                    .fill(g.color.opacity(0.2))
                                                    .frame(height: 4)
                                                    .overlay(
                                                        GeometryReader { geo in
                                                            Capsule()
                                                                .fill(g.color)
                                                                .frame(width: max(4, geo.size.width * CGFloat(pct) / 100.0))
                                                        },
                                                        alignment: .leading
                                                    )
                                                    .padding(.top, 4)
                                                
                                                Text("\(pct)% of total")
                                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                                    .foregroundColor(g.color)
                                            }
                                            .padding(14)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(g.color.opacity(0.06))
                                            .cornerRadius(14)
                                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(g.color.opacity(0.2), lineWidth: 1))
                                        }
                                    }
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                                .padding(.horizontal, 20)
                            }
                            
                            // ── PATIENTS NEEDING ATTENTION ──
                            if withPending > 0 {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        HStack(spacing: 8) {
                                            Image(systemName: "clock.badge.exclamationmark")
                                                .foregroundColor(Color(hex: "F59E0B"))
                                            Text("Patients Needing Attention")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "0F172A"))
                                        }
                                        Spacer()
                                        Button(action: { selectedTab = 0 }) {
                                            Text("View all →")
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "3B82F6"))
                                        }
                                    }
                                    
                                    VStack(spacing: 10) {
                                        ForEach(patients.filter { ($0.pending_reviews ?? 0) > 0 }, id: \.patient_id) { p in
                                            NavigationLink {
                                                PatientReportsListView(patient: p)
                                                    .environmentObject(LanguageManager.shared)
                                            } label: {
                                                HStack(spacing: 14) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color(hex: "FEF3C7"))
                                                            .frame(width: 40, height: 40)
                                                        Text(String(p.name.prefix(1)).uppercased())
                                                            .font(.system(size: 16, weight: .black, design: .rounded))
                                                            .foregroundColor(Color(hex: "D97706"))
                                                    }
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(p.name)
                                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                                            .foregroundColor(Color(hex: "0F172A"))
                                                        Text("ID: #\(String(p.patient_id.suffix(4))) · \(p.age ?? 0) yrs · \(p.sex ?? "")")
                                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                                            .foregroundColor(Color(hex: "64748B"))
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Text("\(p.pending_reviews ?? 0) pending")
                                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                                        .foregroundColor(Color(hex: "D97706"))
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(Color(hex: "FEF3C7"))
                                                        .cornerRadius(12)
                                                }
                                                .padding(12)
                                                .background(Color(hex: "FFFBEB"))
                                                .cornerRadius(14)
                                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "FDE68A"), lineWidth: 1))
                                            }
                                        }
                                    }
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            
            VStack {
                Spacer()
                CustomDoctorTabBar(selectedTab: $selectedTab)
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            fetchPatients()
        }
    }
    
    private func fetchPatients() {
        let doctorID = UserDefaults.standard.string(forKey: "current_doctor_id") ?? ""
        NetworkManager.shared.getPatientsList(doctorID: doctorID) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let res):
                    if res.success {
                        self.patients = res.patients ?? []
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
}

// ── MINI KPI CARD ──
struct AnalyticsKpiCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var bgColor: Color = Color.white
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "0F172A"))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "64748B"))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
}
