import SwiftUI
import UIKit
import GoogleSignIn
import GoogleSignInSwift

@available(iOS 16.0, *)
struct DMGoogleSignInButton: View {
    var isLoading: Bool
    var completion: (Result<GoogleSignInCredentials, Error>) -> Void

    var body: some View {
        let viewModel = GoogleSignInButtonViewModel(
            scheme: .light,
            style: .wide,
            state: isLoading ? .disabled : .normal
        )

        return ZStack {
            GoogleSignInButton(viewModel: viewModel) {
                signIn()
            }
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .dmShadow()
            .opacity(isLoading ? 0 : 1)

            if isLoading {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                    )
                    .frame(height: 52)
                    .dmShadow()
            }
        }
        .frame(maxWidth: .infinity)
        .allowsHitTesting(!isLoading)
    }

    private func signIn() {
        guard !isLoading else { return }

        guard let presentingViewController = topViewController() else {
            completion(.failure(SignInError.missingPresentingViewController))
            return
        }

        guard GIDSignIn.sharedInstance.configuration != nil else {
            completion(.failure(SignInError.missingClientID))
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(SignInError.userUnavailable))
                return
            }

            guard let identifier = user.userID ?? user.idToken?.tokenString else {
                completion(.failure(SignInError.userUnavailable))
                return
            }

            let credentials = GoogleSignInCredentials(
                userID: identifier,
                email: user.profile?.email,
                fullName: user.profile?.name
            )

            completion(.success(credentials))
        }
    }

    private func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    private enum SignInError: LocalizedError {
        case missingPresentingViewController
        case missingClientID
        case userUnavailable

        var errorDescription: String? {
            switch self {
            case .missingPresentingViewController:
                return "Unable to present Google Sign-In right now. Please try again."
            case .missingClientID:
                return "Google Sign-In isn't configured yet. Add your client ID in Info.plist."
            case .userUnavailable:
                return "We couldn't retrieve your Google account."
            }
        }
    }
}
