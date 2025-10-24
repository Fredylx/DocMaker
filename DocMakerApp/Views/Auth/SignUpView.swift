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

                if let error = appState.authError {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                DMButton(
                    title: "Sign Up",
                    isEnabled: appState.canAttemptSignUp && !appState.isAuthenticating,
                    isLoading: appState.isAuthenticating
                ) {
                    Task {
                        await appState.signUp()
                    }
                }

                DMGoogleSignInButton(isLoading: appState.isAuthenticating) { result in
                    appState.handleGoogleSignIn(result: result)
                }

                DMAppleSignInButton(isLoading: appState.isAuthenticating) { result in
                    appState.handleAppleSignIn(result: result)
                }

                DMButton(title: "Already have an account?", style: .text, uppercase: false) {
                    appState.clearAuthError()
                    appState.push(.logIn)
                }
            }
        }
        .onChange(of: appState.signUpData) { _ in
            appState.clearAuthError()
        }
        .onAppear {
            appState.clearAuthError()
        }
    }
}
