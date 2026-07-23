import SwiftUI

struct AddPatientView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddPatientViewModel()

    var onAdd: (Patient) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Patient Information") {
                    TextField("Full Name", text: $viewModel.name)
                    TextField("Patient ID", text: $viewModel.patientID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Age (years)", text: $viewModel.age)
                        .keyboardType(.numberPad)
                    DatePicker("Date of Birth", selection: $viewModel.dob, displayedComponents: .date)
                    Picker("Sex", selection: $viewModel.sex) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                }

                Section("Contact & Security") {
                    TextField("Phone Number", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                    SecureField("Login Password", text: $viewModel.password)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundColor(.red)
                    }
                }

                Section {
                    Button {
                        viewModel.addPatient { success in
                            if success { dismiss() }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("SAVE PATIENT")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.patientID.isEmpty || viewModel.password.isEmpty)
                }
            }
            .navigationTitle("New Patient")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
