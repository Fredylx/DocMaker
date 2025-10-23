import SwiftUI

struct SpouseInfoView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMFormScreen(title: "Spouse Info") {
            DMFormField("Name") {
                TextField("Enter name...", text: $appState.spouse.name)
                    .textInputAutocapitalization(.words)
            }

            DMFormField("Spouse Full Name") {
                TextField("Enter spouse full name...", text: $appState.spouse.fullName)
                    .textInputAutocapitalization(.words)
            }

            DMFormField("Email") {
                TextField("Enter email...", text: $appState.spouse.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            DMFormField("Phone") {
                TextField("Enter phone...", text: $appState.spouse.phone)
                    .keyboardType(.phonePad)
            }

            DMButton(title: "Add Children Info", style: .secondary) {
                appState.push(.children)
            }
        }
    }
}
