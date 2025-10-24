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

                if let error = appState.authError {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                DMButton(
                    title: "Log In",
                    isEnabled: appState.canAttemptLogIn && !appState.isAuthenticating,
                    isLoading: appState.isAuthenticating
                ) {
                    Task {
                        await appState.logIn()
                    }
                }

                DMAppleSignInButton(isLoading: appState.isAuthenticating) { result in
                    appState.handleAppleSignIn(result: result)
                }

                HStack {
                    Button("Forgot password?", action: {})
                        .buttonStyle(.plain)
                        .foregroundColor(.dmPrimary)
                        .font(.subheadline)

                    Spacer()

                    Button("Signup", action: {
                        appState.clearAuthError()
                        appState.push(.signUp)
                    })
                    .buttonStyle(.plain)
                    .foregroundColor(.dmPrimary)
                    .font(.subheadline)
                }
            }
        }
        .onChange(of: appState.logInData) { _ in
            appState.clearAuthError()
        }
        .onAppear {
            appState.clearAuthError()
        }
    }
}
