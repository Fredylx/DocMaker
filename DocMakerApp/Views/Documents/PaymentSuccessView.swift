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
                            VStack(spacing: 18) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(Color.dmPrimary)

                                Text("Stripe test payment authorized")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextPrimary)

                                if let receipt = appState.lastPaymentReceipt {
                                    VStack(spacing: 8) {
                                        Text("Amount: \(receipt.formattedAmount)")
                                            .font(.subheadline)
                                            .foregroundColor(.dmTextSecondary)
                                        Text("Confirmation: \(receipt.confirmationCode)")
                                            .font(.subheadline)
                                            .foregroundColor(.dmTextSecondary)
                                        Text("Card ending in \(receipt.last4)")
                                            .font(.subheadline)
                                            .foregroundColor(.dmTextSecondary)
                                        Text("Authorized on \(receipt.formattedDate)")
                                            .font(.footnote)
                                            .foregroundColor(.dmTextSecondary)
                                    }
                                } else {
                                    Text("Your test authorization for $49 succeeded.")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.dmTextSecondary)
                                }

                                Text("Swap in your live Stripe publishable and secret keys to move this flow out of test mode.")
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.dmTextSecondary)
                                    .padding(.top, 8)
                            }
                            .padding(24)
                        )
                }

                DMButton(title: "Back to checkout", style: .secondary, uppercase: false) {
                    appState.pop()
                }
            }
        }
    }
}
