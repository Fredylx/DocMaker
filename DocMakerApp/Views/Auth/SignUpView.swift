import SwiftUI

@available(iOS 16.0, *)
@available(iOS 16.0, *)
struct SignUpView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMAuthContainer(title: "Sign Up", subtitle: "Create your secure documents workspace") {
            VStack(spacing: DMSpacing.stack) {
                DMFormField("Email") {
                    TextField("Enter email...", text: $appState.signUpData.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                DMFormField("Password") {
                    SecureField("Enter password...", text: $appState.signUpData.password)
                }

                DMFormField("Full Name") {
                    TextField("Enter full name...", text: $appState.signUpData.fullName)
                        .textInputAutocapitalization(.words)
                }

                DMButton(title: "Sign Up") {
                    appState.navigateToHome()
                }

                DMButton(title: "Already have an account?", style: .text, uppercase: false) {
                    appState.push(.logIn)
                }
            }
        }
    }
}
