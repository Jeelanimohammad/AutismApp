import SwiftUI

// MARK: - Profile Picture View
struct ProfilePictureView: View {
    @Binding var profileImage: Image?
    @Binding var showImagePicker: Bool

    var body: some View {
        VStack {
            ZStack {
                if let image = profileImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                }
            }
            .shadow(radius: 8)
            .onTapGesture { showImagePicker = true }

            Text("Upload Profile Picture")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 6)
        }
        .padding(.top, 30)
    }
}

// MARK: - Doctor Form Card
struct FormCardViewDoctor: View {
    @Binding var name: String
    @Binding var dob: Date
    let age: Int
    @Binding var sex: String
    let sexOptions: [String]
    @Binding var doctorID: String
    @Binding var phoneNumber: String
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        VStack(spacing: 20) {

            Group {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full Name").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter name", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Date of Birth").font(.caption).foregroundColor(.white.opacity(0.8))
                    DatePicker("", selection: $dob, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack {
                    Text("Age:").font(.caption).foregroundColor(.white.opacity(0.8))
                    Text("\(age) years").font(.subheadline).foregroundColor(.white).bold()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Sex").font(.caption).foregroundColor(.white.opacity(0.8))
                    Picker("Sex", selection: $sex) {
                        ForEach(sexOptions, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .colorScheme(.dark)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Doctor ID").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter doctor ID", text: $doctorID)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Phone Number").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter phone number", text: $phoneNumber)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .keyboardType(.phonePad)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Email").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Password").font(.caption).foregroundColor(.white.opacity(0.8))
                    CustomPasswordField(placeholder: "Enter password", text: $password)
                }
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.15))
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 15)
        .padding(.horizontal, 24)
    }
}

// MARK: - Patient Form Card
struct FormCardView: View {
    @Binding var name: String
    @Binding var dob: Date
    let age: Int
    @Binding var sex: String
    let sexOptions: [String]
    @Binding var patientID: String
    @Binding var phoneNumber: String
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        VStack(spacing: 20) {

            Group {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full Name").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter name", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Date of Birth").font(.caption).foregroundColor(.white.opacity(0.8))
                    DatePicker("", selection: $dob, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack {
                    Text("Age:").font(.caption).foregroundColor(.white.opacity(0.8))
                    Text("\(age) years").font(.subheadline).foregroundColor(.white).bold()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Sex").font(.caption).foregroundColor(.white.opacity(0.8))
                    Picker("Sex", selection: $sex) {
                        ForEach(sexOptions, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .colorScheme(.dark)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Patient ID").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter patient ID", text: $patientID)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Phone Number").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter phone number", text: $phoneNumber)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .keyboardType(.phonePad)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Email").font(.caption).foregroundColor(.white.opacity(0.8))
                    TextField("Enter email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Password").font(.caption).foregroundColor(.white.opacity(0.8))
                    CustomPasswordField(placeholder: "Enter password", text: $password)
                }
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.15))
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 15)
        .padding(.horizontal, 24)
    }
}

// MARK: - CUSTOM SECURE FIELD WITH TOGGLE
struct CustomPasswordField: View {
    var title: String? = nil
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var accentColor: Color = .blue // Default to clinical blue
    
    @State private var isVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = title {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded)) // Bolder
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4)) // Darker Slate
                    .padding(.leading, 4)
            }
            
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(accentColor)
                        .font(.system(size: 18))
                        .frame(width: 24)
                }
                
                if isVisible {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                        .foregroundColor(Color.black.opacity(0.8))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray.opacity(0.5)))
                        .foregroundColor(Color.black.opacity(0.8))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.25)) // High-attention Deep Navy
                        .font(.system(size: 16))
                }
            }
            .padding()
            .background(Color.black.opacity(0.02))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }
}
