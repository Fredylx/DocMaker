import SwiftUI

@available(iOS 16.0, *)
@available(iOS 16.0, *)
struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 24)

                Text("Doc Maker")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.dmPrimary)

                VStack(spacing: 24) {
                    Image(systemName: "doc.richtext")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .foregroundColor(.dmPrimary)
                        .padding(.top, 24)

                    if let user = appState.authenticatedUser {
                        VStack(spacing: 12) {
                            Text("Signed in as \(user.fullName)")
                                .font(.subheadline)
                                .foregroundColor(.dmTextSecondary)

                            DMButton(title: "Continue to Dashboard") {
                                appState.navigateToHome()
                            }

                            Button("Not you? Sign out") {
                                appState.signOut()
                            }
                            .buttonStyle(.plain)
                            .font(.subheadline)
                            .foregroundColor(.dmPrimary)
                        }
                    } else {
                        DMButton(title: "Sign Up") {
                            appState.clearAuthError()
                            appState.push(.signUp)
                        }

                        if let error = appState.authError {
                            Text(error)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        DMGoogleSignInButton(isLoading: appState.isAuthenticating) { result in
                            appState.handleGoogleSignIn(result: result)
                        }

                        DMAppleSignInButton(isLoading: appState.isAuthenticating) { result in
                            appState.handleAppleSignIn(result: result)
                        }

                        Button(action: {
                            appState.clearAuthError()
                            appState.push(.logIn)
                        }) {
                            Text("Already have an account?")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.dmPrimary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .dmCardBackground()
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}
