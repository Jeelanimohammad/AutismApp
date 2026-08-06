import SwiftUI

struct DoctorDetailsView: View {
    // MARK: - State Variables
    @StateObject private var viewModel = DoctorRegistrationViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Animations
    @State private var showContent = false
    @State private var orbPulse = false
    
    let sexOptions = ["Male", "Female", "Other"]
    
    var body: some View {
        StandardBackground {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // MARK: Header Profile Section
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("Professional Profile")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.02, green: 0.1, blue: 0.3)) // Deep Navy
                            Text("Standardizing clinical provider data")
                                .font(.system(size: 14, weight: .bold, design: .rounded)) // Bolder
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4)) // Darker Slate
                        }
                    }
                    .padding(.top, 40)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.9)

                    // MARK: Registration Form
                    VStack(spacing: 24) {
                        
                        // Personal Information Section Title
                        formSectionTitle(title: "IDENTITY DETAILS", icon: "person.text.rectangle.fill")
                        
                        PremiumRegField(title: "FULL NAME", placeholder: "Enter doctor name", text: $viewModel.name, icon: "person.fill")
                        
                        // Age & Gender Row
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("SEX")
                                    .font(.system(size: 11, weight: .black)) // Max Bold
                                    .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.45)) // Darker Slate
                                
                                Picker("Sex", selection: $viewModel.sex) {
                                    ForEach(sexOptions, id: \.self) { Text($0).tag($0) }
                                }
                                .pickerStyle(.segmented)
                                .scaleEffect(0.9)
                                .frame(height: 48)
                                .background(Color.black.opacity(0.02))
                                .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("DATE OF BIRTH")
                                    .font(.system(size: 11, weight: .black)) // Max Bold
                                    .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.45)) // Darker Slate
                                
                                DatePicker("", selection: $viewModel.dob, in: ...Date(), displayedComponents: .date)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.black.opacity(0.02))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.05), lineWidth: 1))
                            }
                        }
                        
                        HStack {
                            Text("CALCULATED AGE: ")
                                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5)) // Darker Gray
                            Text("\(viewModel.age) YEARS")
                                .foregroundColor(.cyan)
                                .fontWeight(.black)
                        }
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -8)

                        Divider().background(Color.black.opacity(0.05))

                        formSectionTitle(title: "ACCOUNT & CONTACT", icon: "lock.shield.fill")

                         PremiumRegField(title: "DOCTOR ID", placeholder: "e.g. DOC77521", text: $viewModel.doctorID, icon: "cross.case.fill")
                        
                        PremiumRegField(title: "PHONE NUMBER", placeholder: "Enter contact number", text: $viewModel.phoneNumber, icon: "phone.fill", keyboard: .phonePad)
                        
                        PremiumRegField(title: "EMAIL ADDRESS", placeholder: "Enter clinical email", text: $viewModel.email, icon: "envelope.fill", keyboard: .emailAddress)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            PremiumRegField(title: "ACCOUNT PASSWORD", placeholder: "Secure access code", text: $viewModel.password, icon: "key.fill", isSecure: true)
                        }

                        // Action Button
                        Button(action: {
                            hideKeyboard()
                            viewModel.register()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.05, green: 0.6, blue: 0.35), Color(red: 0.1, green: 0.8, blue: 0.45)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color(red: 0.05, green: 0.6, blue: 0.35).opacity(0.3), radius: 15, x: 0, y: 8)
                                    .opacity(viewModel.canRegister ? 1 : 0.4)

                                HStack(spacing: 12) {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("COMPLETE REGISTRATION")
                                            .font(.system(size: 15, weight: .black, design: .rounded)) // Max Bold
                                            .tracking(1.2)
                                        Image(systemName: "stethoscope.circle.fill")
                                            .font(.system(size: 18))
                                    }
                                }
                                .foregroundColor(.white)
                            }
                            .frame(height: 62)
                        }
                        .disabled(!viewModel.canRegister || viewModel.isLoading)
                        .padding(.top, 16)
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
                    .offset(y: showContent ? 0 : 30)
                }
                .padding(.bottom, 60)
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
        .onAppear {
            orbPulse = true
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
        }
        .onChange(of: viewModel.navigateToDashboard) { old, newValue in
            if newValue {
                dismiss() // Pop back to Login Screen
            }
        }
        .alert("Registration Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func formSectionTitle(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.05, green: 0.6, blue: 0.35)) // Emerald Doctor Theme
                .font(.system(size: 14, weight: .bold))
            Text(title)
                .font(.system(size: 11, weight: .black, design: .monospaced)) // Max Bold
                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4)) // Darker Slate
                .tracking(1.5)
            Spacer()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Premium Field
private struct PremiumRegField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    
    @State private var showPassword = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .black)) // Max Bold
                .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.45)) // Darker Slate
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.cyan) // Scientific/Professional Cyan
                    .font(.system(size: 16))
                    .frame(width: 24)
                
                if isSecure {
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                        } else {
                            SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.25)) // High-attention Deep Navy (Ebony)
                                .font(.system(size: 14))
                        }
                    }
                    .foregroundColor(Color.black.opacity(0.8))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                        .foregroundColor(Color.black.opacity(0.8))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: text) { oldValue, newValue in
                            if keyboard == .phonePad {
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered.count > 10 {
                                    text = String(filtered.prefix(10))
                                } else {
                                    text = filtered
                                }
                            }
                        }
                }
            }
            .padding()
            .background(Color.black.opacity(0.02))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
}

#Preview {
    NavigationStack {
        DoctorDetailsView()
    }
}
