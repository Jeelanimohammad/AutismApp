import SwiftUI

struct ChangePasswordView: View {
    var themeColor: Color // Role-based theme (Orange for Patient, Emerald for Doctor)
    
    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Validation
    var passwordValid: Bool {
        isValidPassword(newPassword) && newPassword == confirmPassword
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 4
    }
    
    var body: some View {
        StandardBackground {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    Spacer(minLength: 40)
                    
                    // MARK: - HEADER
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [themeColor, themeColor.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: themeColor.opacity(0.3), radius: 10)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Reset Password")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                            
                            Text("Update your security credentials")
                                .font(.system(size: 14, weight: .black, design: .rounded)) // Max Bold
                                .foregroundColor(Color(red: 0.05, green: 0.15, blue: 0.35)) // Darker Navy
                        }
                    }
                    
                    // MARK: - INPUT CARD
                    VStack(spacing: 24) {
                        // Email (Non-editable or as lookup)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Account Email")
                                .font(.system(size: 13, weight: .bold, design: .rounded)) // Bolder
                                .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.45)) // Darker Slate
                                .padding(.leading, 4)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.cyan) // Scientific/Professional Cyan for sub-icons
                                    .frame(width: 24)
                                TextField("Enter registered email", text: $email)
                                    .foregroundColor(Color.black.opacity(0.8))
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .textInputAutocapitalization(.never)
                            }
                            .padding()
                            .background(Color.black.opacity(0.02))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
                        }
                        
                        // New Password
                        CustomPasswordField(
                            title: "New Password",
                            placeholder: "Enter new password",
                            text: $newPassword,
                            icon: "lock.fill",
                            accentColor: .cyan
                        )
                        
                        // Confirm Password
                        CustomPasswordField(
                            title: "Confirm Password",
                            placeholder: "Repeat new password",
                            text: $confirmPassword,
                            icon: "checkmark.shield.fill",
                            accentColor: .cyan
                        )
                        
                        // Validation Checklist
                        VStack(alignment: .leading, spacing: 10) {
                            validationRow("At least 4 characters", newPassword.count >= 4)
                            
                            if !confirmPassword.isEmpty {
                                HStack {
                                    Image(systemName: newPassword == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    Text(newPassword == confirmPassword ? "Passwords match" : "Passwords do not match")
                                }
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(newPassword == confirmPassword ? .green : .red)
                            }
                        }
                        .padding(.top, 4)
                        
                        // Action Button
                        Button(action: updatePassword) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [themeColor, themeColor.opacity(0.9)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: themeColor.opacity(0.3), radius: 10, y: 5)
                                
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("UPDATE SECURELY")
                                        .font(.system(size: 15, weight: .black, design: .rounded)) // Max Bold
                                        .foregroundColor(.white)
                                        .tracking(1.2)
                                }
                            }
                            .frame(height: 55)
                        }
                        .opacity(passwordValid && !email.isEmpty && !isLoading ? 1.0 : 0.6)
                        .disabled(!passwordValid || email.isEmpty || isLoading)
                    }
                    .padding(28)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.black.opacity(0.6))
                        .padding(10)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if alertMessage.contains("Successfully") {
                    dismiss()
                }
            }
        }
    }
    
    private func validationRow(_ text: String, _ condition: Bool) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(condition ? Color.green : Color.cyan.opacity(0.4)) // Cyan for consistency
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 13, weight: .black, design: .rounded)) // Max Bold
                .foregroundColor(condition ? .green : Color(red: 0.1, green: 0.2, blue: 0.4)) // High contrast slate
        }
    }
    
    @State private var isLoading = false
    
    private func updatePassword() {
        let lowercasedEmail = email.lowercased()
        if !(lowercasedEmail.hasSuffix("@gmail.com") || lowercasedEmail.hasSuffix("@yahoo.com") || lowercasedEmail.hasSuffix("@saveetha.com") || lowercasedEmail.hasSuffix("@outlook.com") || lowercasedEmail.hasSuffix("@hotmail.com")) {
            alertMessage = "Invalid Email: Must end with @yahoo.com, @saveetha.com, @outlook.com, @hotmail.com, or @gmail.com"
            showAlert = true
            return
        }
        
        isLoading = true
        let params = ["email": email, "password": newPassword]
        
        NetworkManager.shared.resetPassword(parameters: params) { result in
            isLoading = false
            switch result {
            case .success(let response):
                if response.success {
                    alertMessage = "Password Updated Successfully 🎉"
                } else {
                    alertMessage = response.message ?? "Failed to update password"
                }
            case .failure(let error):
                alertMessage = "Network Error: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }
}

#Preview {
    ChangePasswordView(themeColor: .orange)
}
