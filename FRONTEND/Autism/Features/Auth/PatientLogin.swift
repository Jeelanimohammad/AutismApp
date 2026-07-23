import SwiftUI

struct PatientLoginView: View {
    @StateObject private var viewModel = PatientLoginViewModel()
    @EnvironmentObject var languageManager: LanguageManager
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
                        // Brand Icon
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 90, height: 90)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "figure.and.child.holdinghands")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, Color(red: 1.0, green: 0.6, blue: 0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .orange.opacity(0.4), radius: 10)
                        }
                        .scaleEffect(showContent ? 1 : 0.8)
                        .opacity(showContent ? 1 : 0)

                        VStack(spacing: 8) {
                            Text("welcome_back".localizedPatient())
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy for crystal clarity
                            
                            Text("login_subtitle".localizedPatient())
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
                        
                        // Patient ID Field
                        PremiumTextField(
                            title: "patient_id_label".localizedPatient(),
                            placeholder: "enter_id_placeholder".localizedPatient(),
                            text: $viewModel.patientID,
                            icon: "number.circle.fill"
                        )
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            PremiumSecureField(
                                title: "password_label".localizedPatient(),
                                placeholder: "password_placeholder".localizedPatient(),
                                text: $viewModel.password,
                                icon: "lock.shield.fill"
                            )
                            
                            if !viewModel.password.isEmpty && !viewModel.passwordValidation.isEmpty {
                                Text(viewModel.passwordValidation.joined(separator: ", "))
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.red)
                                    .padding(.leading, 4)
                                    .transition(.opacity)
                            }
                        }

                        // Forgot Password
                        NavigationLink(destination: ChangePasswordView(themeColor: .orange).environmentObject(LanguageManager.shared)) {
                            Text("forgot_password".localizedPatient())
                                .font(.system(size: 13, weight: .bold, design: .rounded)) // Bolder
                                .foregroundColor(.orange) // Patient Amber
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
                                            colors: [.orange, Color(red: 1.0, green: 0.5, blue: 0.0)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.orange.opacity(0.3), radius: 15, x: 0, y: 8)
                                    .opacity(viewModel.isLoginEnabled ? 1 : 0.5)

                                HStack(spacing: 12) {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("log_in_button".localizedPatient())
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .tracking(1.5)
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 20))
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
            PatientDashboardView(isPresented: $viewModel.navigateToDashboard, patientID: viewModel.patientID)
                .environmentObject(LanguageManager.shared)
        }
        .alert("login_failed_title".localizedPatient(), isPresented: $viewModel.showError) {
            Button("ok".localizedPatient(), role: .cancel) { }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded)) // Bolder
                .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.5)) // Darker Slate
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.orange) // Patient Amber
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                    .foregroundColor(Color.black.opacity(0.8))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
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
                .foregroundColor(Color(red: 0.15, green: 0.3, blue: 0.5)) // Darker slate for clarity
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.cyan) // Scientific/Professional Cyan for sub-icons
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
        PatientLoginView()
    }
}
