import SwiftUI

@available(iOS 16.0, *)
struct ContactUsView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var message: String = ""
    @State private var showConfirmation = false

    var body: some View {
        DMFormScreen(title: "Contact Us") {
            VStack(alignment: .leading, spacing: 16) {
                contactHeader

                DMFormField("Name") {
                    TextField("Your name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                DMFormField("Email") {
                    TextField("you@email.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                DMFormField("Phone") {
                    TextField("+1 (555) 123-4567", text: $phone)
                        .keyboardType(.phonePad)
                }

                DMFormField("Message") {
                    TextEditor(text: $message)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.dmBorder, lineWidth: 1)
                        )
                }

                DMButton(title: "Send Message", uppercase: false) {
                    showConfirmation = true
                }
                .disabled(name.isEmpty || email.isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .alert("Message Sent", isPresented: $showConfirmation) {
                    Button("Great", role: .cancel) {
                        resetForm()
                    }
                } message: {
                    Text("Our team will reach out to you at \(email) within one business day.")
                }
            }
        }
    }

    private var contactHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.dmTextSecondary)
            Text("contact-us@mail.com")
                .font(.headline)
                .foregroundColor(.dmTextPrimary)

            Text("Phone")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.dmTextSecondary)
            Text("+1 855-492-6735")
                .font(.headline)
                .foregroundColor(.dmTextPrimary)
        }
    }

    private func resetForm() {
        name = ""
        email = ""
        phone = ""
        message = ""
    }
}
