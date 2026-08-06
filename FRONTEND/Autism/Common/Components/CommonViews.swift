import SwiftUI

// MARK: - Shared Background
struct StandardBackground<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Premium SkyBlue Clinical Background
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.55, blue: 1.0), // Deep Sky Blue
                        Color(red: 0.4, green: 0.8, blue: 1.0),  // Vivid Azure
                        Color(red: 0.7, green: 0.9, blue: 1.0)   // Light Sky Blue
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Pure Dynamic depth orbs
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 450, height: 450)
                    .blur(radius: 90)
                    .offset(x: -180, y: -300)
                
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 450, height: 450)
                    .blur(radius: 100)
                    .offset(x: 180, y: 350)
            }
                
            content
                .foregroundColor(.black)
        }
    }
}

// MARK: - Icon Input Field
struct IconInputField: View {
    let title: String
    @Binding var text: String
    var icon: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.85))
            
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                    .allowsHitTesting(false)
                
                if isSecure {
                    SecureField("", text: $text)
                        .textContentType(.password)
                } else {
                    TextField("", text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Password Field With Validation
struct PasswordFieldWithValidation: View {
    @Binding var password: String
    
    var passwordValidation: [String] {
        var messages: [String] = []
        if password.count < 4 { messages.append("• Minimum 4 characters") }
        return messages
    }
    
    var isPasswordValid: Bool { passwordValidation.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Password")
                .font(.caption)
                .foregroundColor(.black.opacity(0.85))
            
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                    .allowsHitTesting(false)
                
                SecureField("", text: $password)
                    .textContentType(.password)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            
            if !isPasswordValid && !password.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(passwordValidation, id: \.self) { msg in
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 2)
            }
        }
    }
}

// MARK: - Role Card
struct RoleBox: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 60, height: 60)
                .cornerRadius(15)
                .shadow(color: gradient.first!.opacity(0.4), radius: 6)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6)
        )
    }
}
