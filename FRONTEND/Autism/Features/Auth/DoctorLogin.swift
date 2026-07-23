import SwiftUI

struct DoctorLoginView: View {
    @StateObject private var viewModel = DoctorLoginViewModel()
    @Environment(\.dismiss) var dismiss

    // animations
    @State private var showContent = false
    @State private var orbPulse = false

    var body: some View {
        StandardBackground {
            // ── Main Content ───────────────────────────────────────────────
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // MARK: Header
                    VStack(spacing: 16) {
                        // Professional Icon
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 90, height: 90)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, Color(red: 0.0, green: 0.6, blue: 0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .green.opacity(0.3), radius: 10)
                        }
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)

                        VStack(spacing: 8) {
                            Text("professional_access".localizedDoctor())
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy for crystal clarity
                            
                            Text("clinical_dashboard_care_providers".localizedDoctor())
                                .font(.system(size: 14, weight: .bold, design: .rounded)) // Bolder as requested
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4)) // Darker Slate for contrast
                                .multilineTextAlignment(.center)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 10)
                    }
                    .padding(.top, 60)

                    // MARK: Login Card
                    VStack(spacing: 24) {
                        
                        // Email Field
                        PremiumTextField(
                            title: "professional_email".localizedDoctor(),
                            placeholder: "doctor@hospital.com",
                            text: $viewModel.email,
                            icon: "envelope.badge.shield.half.filled",
                            keyboardType: .emailAddress
                        )
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 10) {
                            PremiumSecureField(
                                title: "security_password".localizedDoctor(),
                                placeholder: "enter_credentials".localizedDoctor(),
                                text: $viewModel.password,
                                icon: "lock.rectangle.stack.fill"
                            )
                            .onChange(of: viewModel.password) {
                                viewModel.validatePassword()
                            }
                            
                            if !viewModel.passwordMessage.isEmpty {
                                HStack(spacing: 4) {
                                    Circle().fill(viewModel.passwordColor).frame(width: 6, height: 6)
                                    Text(viewModel.passwordMessage)
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(viewModel.passwordColor)
                                }
                                .padding(.leading, 4)
                                .transition(.opacity)
                            }
                        }

                        // Forgot Password
                        NavigationLink(destination: ChangePasswordView(themeColor: Color(red: 0.05, green: 0.6, blue: 0.35))) {
                            Text("forgot_password".localizedDoctor())
                                .font(.system(size: 13, weight: .bold, design: .rounded)) // Bolder
                                .foregroundColor(.green) // Doctor Emerald
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        
                        // Login Button
                        Button(action: { 
                            hideKeyboard()
                            viewModel.login() 
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, Color(red: 0.0, green: 0.6, blue: 0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.green.opacity(0.3), radius: 15, x: 0, y: 8)
                                    .opacity(viewModel.isLoginEnabled ? 1 : 0.5)

                                HStack(spacing: 12) {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("authorize_login".localizedDoctor())
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .tracking(1.2)
                                        Image(systemName: "checkmark.shield.fill")
                                            .font(.system(size: 18))
                                    }
                                }
                                .foregroundColor(.white)
                            }
                            .frame(height: 60)
                        }
                        .disabled(!viewModel.isLoginEnabled || viewModel.isLoading)
                        .padding(.top, 8)
                    }
                    .padding(28)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.black.opacity(0.04), lineWidth: 1)
                        }
                    )
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    
                    // Support Text
                    VStack(spacing: 4) {
                        Text("authorized_clinical_use".localizedDoctor())
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.gray.opacity(0.8))
                        Text("saveetha_network".localizedDoctor())
                            .font(.system(size: 11))
                            .foregroundColor(Color.gray)
                    }
                    .padding(.top, 10)
                    .opacity(showContent ? 1 : 0)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
        .fullScreenCover(isPresented: $viewModel.navigateToDashboard) {
            DoctorDashboardView(isPresented: $viewModel.navigateToDashboard)
                .environmentObject(LanguageManager.shared)
        }
        .alert("authorization_failed".localizedDoctor(), isPresented: $viewModel.showError) {
            Button("ok".localizedDoctor(), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            orbPulse = true
            withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Premium Field Components
private struct PremiumTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded)) // Bolder
                .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.45)) // Darker Slate
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.green) // Doctor Emerald
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                    .foregroundColor(Color.black.opacity(0.8))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding()
            .background(Color.black.opacity(0.02))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
}

private struct PremiumSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    @State private var isVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded)) // Bolder as requested
                .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.45)) // Darker slate for clarity
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.cyan) // Professional clinical highlight
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                if isVisible {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                        .foregroundColor(Color.black.opacity(0.8))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                        .foregroundColor(Color.black.opacity(0.8))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.25)) // High-attention Deep Navy
                        .font(.system(size: 14))
                }
            }
            .padding()
            .background(Color.black.opacity(0.02))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
}

#Preview {
    NavigationStack {
        DoctorLoginView()
    }
}
