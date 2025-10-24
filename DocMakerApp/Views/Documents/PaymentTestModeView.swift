import SwiftUI

@available(iOS 16.0, *)
struct PaymentTestModeView: View {
    @EnvironmentObject private var appState: AppState

    private let priceDescription = "$49 one-time access"

    var body: some View {
        DMFormScreen(title: "Stripe Payment (Test Mode)") {
            VStack(spacing: 20) {
                paymentSummaryCard
                instructionsCard
                DMButton(title: "Simulate $49 Test Payment") {
                    appState.push(.paymentSuccess)
                }
                DMButton(title: "Cancel", style: .text, uppercase: false) {
                    appState.pop()
                }
            }
        }
    }

    private var paymentSummaryCard: some View {
        VStack(spacing: 16) {
            Text("You're almost there")
                .font(.headline)
                .foregroundColor(.dmTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Text("DocMaker Premium")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.dmTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(priceDescription)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.dmPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("This charge will be processed using Stripe's sandbox environment so you can test the checkout flow without live credentials.")
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(Color.dmCardBackground)
            .cornerRadius(20)
            .dmShadow()
        }
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to test the payment")
                .font(.headline)
                .foregroundColor(.dmTextPrimary)

            VStack(alignment: .leading, spacing: 12) {
                instructionRow(text: "Use Stripe's universal test card number 4242 4242 4242 4242 with any valid future expiry date and CVC.")
                instructionRow(text: "All charges are simulated and no real funds are moved. Replace the test publishable key with your live key when you're ready to launch.")
                instructionRow(text: "You'll still get full access to DocMaker features after confirming this test payment.")
            }
            .padding(20)
            .background(Color.dmCardBackground)
            .cornerRadius(20)
            .dmShadow()
        }
    }

    private func instructionRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.dmPrimary)
            Text(text)
                .font(.footnote)
                .foregroundColor(.dmTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
