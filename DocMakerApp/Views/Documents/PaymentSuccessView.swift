import SwiftUI

@available(iOS 16.0, *)
struct PaymentSuccessView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMFormScreen(title: "Payment Complete") {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .dmShadow()
                        .frame(height: 260)
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(Color.dmPrimary)

                                Text("Your test payment for $49 was successfully authorized")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextPrimary)

                                Text("Because this is Stripe's sandbox environment, no real charge was created. Replace the test keys with live credentials when you're ready to go live.")
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextSecondary)
                            }
                            .padding(24)
                        )
                }

                DMButton(title: "Back to documents", style: .secondary, uppercase: false) {
                    appState.pop()
                    appState.pop()
                }
            }
        }
    }
}
