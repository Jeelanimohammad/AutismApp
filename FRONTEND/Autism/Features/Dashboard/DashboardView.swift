import SwiftUI

struct DashboardView: View {
    
    @State private var showPatients = false
    @State private var userEmail = "" // 🔹 Empty by default (no fake email)
    
    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(
                colors: [
                    Color(red: 230/255, green: 240/255, blue: 255/255),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Soft Glow
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 300)
                .blur(radius: 80)
                .offset(x: -150, y: -250)
            
            VStack(spacing: 24) {
                headerView()
                
                statusOverview()
                
                actionList()
                
                Spacer()
                
                bottomNavBar()
            }
            .padding(.top, 10)
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showPatients) {
            PatientsView(selectedTab: .constant(0))
        }
    }
    
    // ✅ FUNCTION TO EXTRACT DOCTOR NAME (ONLY IF VALID)
    func extractDoctorName(from email: String) -> String? {
        guard email.contains("@"), email.contains(".") else {
            return nil
        }
        
        let username = email.components(separatedBy: "@").first ?? ""
        let parts = username.components(separatedBy: ".")
        
        if let last = parts.last, !last.isEmpty {
            return "Dr. \(last.capitalized)"
        }
        
        return nil
    }
    
    // MARK: - Subviews
    
    private func headerView() -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 10/255, green: 40/255, blue: 120/255),
                    Color(red: 40/255, green: 100/255, blue: 220/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .blur(radius: 20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                // ✅ Show name ONLY if valid email
                if let doctorName = extractDoctorName(from: userEmail) {
                    Text(doctorName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("Welcome")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // ✅ Show email only if valid
                if userEmail.contains("@") {
                    Text(userEmail)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(25)
        }
        .frame(height: 150)
        .cornerRadius(25)
        .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 10)
        .padding(.horizontal)
    }
    
    private func statusOverview() -> some View {
        HStack {
            StatusItem(title: "Today", value: "0", color: .blue)
            Spacer()
            StatusItem(title: "Pending", value: "0", color: .orange)
            Spacer()
            StatusItem(title: "Done", value: "0", color: .green)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private func actionList() -> some View {
        VStack(spacing: 16) {
            ActionRow(
                title: "View Patients",
                subtitle: "Check all registered records",
                icon: "person.2.fill",
                color: .blue
            ) {
                showPatients = true
            }
        }
        .padding(.horizontal)
    }
    
    private func bottomNavBar() -> some View {
        HStack {
            NavItem(icon: "house.fill", title: "Home", active: false)
            Spacer()
            NavItem(icon: "square.grid.2x2.fill", title: "Dashboard", active: true)
            Spacer()
            NavItem(icon: "person.fill", title: "Profile", active: false)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 18)
        .background(
            Color.white
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: -5)
        )
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

// MARK: - Components

struct StatusItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    color.opacity(0.15)
                        .frame(width: 50, height: 50)
                        .cornerRadius(14)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct NavItem: View {
    let icon: String
    let title: String
    let active: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(active ? .blue : .gray.opacity(0.6))
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(active ? .blue : .gray.opacity(0.6))
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
