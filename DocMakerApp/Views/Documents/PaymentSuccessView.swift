import SwiftUI

@available(iOS 16.0, *)
struct PaymentSuccessView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        DMFormScreen(title: "Payment") {
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

                                Text("Payment has been successfully authorized")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextPrimary)

                                Text("There is one more step left. Finish your purchase on the merchant's website.")
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextSecondary)
                            }
                            .padding(24)
                        )
                }

                DMButton(title: "Back to merchant", style: .secondary, uppercase: false) {
                    appState.pop()
                }
            }
        }
    }
}
