import SwiftUI
import GoogleSignInSwift

@available(iOS 16.0, *)
struct DMGoogleSignInButton: View {
    var isLoading: Bool
    var action: () -> Void

    var body: some View {
        ZStack {
            GoogleSignInButton(viewModel: .init(style: .wide, colorScheme: .light), action: action)
                .frame(height: 52)
                .opacity(isLoading ? 0 : 1)

            if isLoading {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.gray)
                    )
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .dmShadow()
        .allowsHitTesting(!isLoading)
    }
}
