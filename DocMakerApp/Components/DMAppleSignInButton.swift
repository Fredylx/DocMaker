import SwiftUI
import AuthenticationServices

@available(iOS 16.0, *)
struct DMAppleSignInButton: View {
    var isLoading: Bool
    var action: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        ZStack {
            SignInWithAppleButton(.signIn, onRequest: configure, onCompletion: action)
                .signInWithAppleButtonStyle(.black)
                .opacity(isLoading ? 0 : 1)

            if isLoading {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    )
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .dmShadow()
        .allowsHitTesting(!isLoading)
    }

    private func configure(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
}
