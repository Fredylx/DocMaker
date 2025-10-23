import SwiftUI

@available(iOS 16.0, *)
@available(iOS 16.0, *)
struct PrimaryPersonInfoView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMFormScreen(title: "Primary Person Info") {
            DMFormField("Full Name") {
                TextField("Enter full name...", text: $appState.primaryPerson.fullName)
                    .textInputAutocapitalization(.words)
            }

            DMFormField("Address") {
                TextField("Enter address...", text: $appState.primaryPerson.address)
            }

            DMFormField("Email") {
                TextField("Enter email...", text: $appState.primaryPerson.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            DMFormField("Phone") {
                TextField("Enter phone...", text: $appState.primaryPerson.phone)
                    .keyboardType(.phonePad)
            }

            DMButton(title: "enter Spouse Info", uppercase: false) {
                appState.push(.spouse)
            }
        }
    }
}
