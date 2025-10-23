import SwiftUI

@available(iOS 16.0, *)
struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMAuthContainer(title: "Log In", subtitle: "Welcome back! We kept your documents safe") {
            VStack(spacing: DMSpacing.stack) {
                DMFormField("Email") {
                    TextField("Enter email...", text: $appState.logInData.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                DMFormField("Password") {
                    SecureField("Enter password...", text: $appState.logInData.password)
                }

                DMButton(title: "Log In") {
                    appState.navigateToHome()
                }

                HStack {
                    Button("Forgot password?", action: {})
                        .buttonStyle(.plain)
                        .foregroundColor(.dmPrimary)
                        .font(.subheadline)

                    Spacer()

                    Button("Signup", action: {
                        appState.push(.signUp)
                    })
                    .buttonStyle(.plain)
                    .foregroundColor(.dmPrimary)
                    .font(.subheadline)
                }
            }
        }
    }
}
