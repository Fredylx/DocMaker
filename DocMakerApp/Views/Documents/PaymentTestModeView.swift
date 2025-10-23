import SwiftUI

@available(iOS 16.0, *)
struct PaymentTestModeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openURL) private var openURL
    @State private var isProcessing = false
    @State private var errorMessage: String?

    private let paymentService: StripePaymentServicing
    private let amount: Decimal = 49
    private let currencyCode = "USD"

    init(paymentService: StripePaymentServicing = StripePaymentService.shared) {
        self.paymentService = paymentService
    }

    var body: some View {
        DMFormScreen(title: "DocMaker Pro Checkout") {
            introCard

            if let receipt = appState.lastPaymentReceipt {
                receiptSummary(for: receipt)
            }

            instructionsCard

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }

            DMButton(
                title: "Authorize $49 Test Charge",
                style: .primary,
                uppercase: false,
                isEnabled: !isProcessing,
                isLoading: isProcessing
            ) {
                Task { await authorizePayment() }
            }

            DMButton(title: "Need help with Stripe?", style: .text, uppercase: false) {
                if let url = URL(string: "https://stripe.com/docs/testing") {
                    openURL(url)
                }
            }
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DocMaker Pro")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.dmTextPrimary)

            Text("One-time payment")
                .font(.subheadline)
                .foregroundColor(.dmTextSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("$49")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.dmPrimary)
                Text("USD")
                    .font(.headline)
                    .foregroundColor(.dmTextSecondary)
            }

            Text("We use Stripe's test mode so you can validate the checkout flow without live API keys.")
                .font(.footnote)
                .foregroundColor(.dmTextSecondary)
        }
        .padding(24)
        .background(Color.dmCardBackground)
        .cornerRadius(24)
        .dmShadow()
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How test mode works")
                .font(.headline)
                .foregroundColor(.dmTextPrimary)

            VStack(alignment: .leading, spacing: 12) {
                instructionRow(icon: "1.circle.fill", text: "Tap the authorize button below. We simulate a Stripe PaymentIntent in test mode for \(formattedAmount).")
                instructionRow(icon: "2.circle.fill", text: "Use Stripe's universal test card \("4242 4242 4242 4242"\) with any future expiry and CVC.")
                instructionRow(icon: "3.circle.fill", text: "Replace the mock integration with your live publishable and secret keys when you're ready.")
            }
            .padding(16)
            .background(Color.dmBackground)
            .cornerRadius(18)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Quick test card")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.dmTextPrimary)
                Text("Number: 4242 4242 4242 4242\nExpiry: Any future date\nCVC: Any 3 digits\nZIP: 42424")
                    .font(.footnote)
                    .foregroundColor(.dmTextSecondary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
            .dmShadow()
        }
        .padding(24)
        .background(Color.dmCardBackground)
        .cornerRadius(24)
        .dmShadow()
    }

    private func instructionRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.dmPrimary)
            Text(text)
                .font(.footnote)
                .foregroundColor(.dmTextSecondary)
        }
    }

    private func receiptSummary(for receipt: StripeTestPaymentReceipt) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.dmPrimary)
                Text("Last authorization")
                    .font(.headline)
                    .foregroundColor(.dmTextPrimary)
                Spacer()
            }

            Text("Confirmation: \(receipt.confirmationCode)")
                .font(.subheadline)
                .foregroundColor(.dmTextSecondary)

            Text("Card: •••• \(receipt.last4)")
                .font(.subheadline)
                .foregroundColor(.dmTextSecondary)

            Text("Authorized on \(receipt.formattedDate)")
                .font(.footnote)
                .foregroundColor(.dmTextSecondary)
        }
        .padding(20)
        .background(Color.dmCardBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.dmBorder, lineWidth: 1)
        )
    }

    private var formattedAmount: String {
        StripePaymentService.currencyFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$49.00"
    }

    private func authorizePayment() async {
        isProcessing = true
        errorMessage = nil

        do {
            let receipt = try await paymentService.authorizeTestPayment(amount: amount, currency: currencyCode)
            appState.lastPaymentReceipt = receipt
            appState.push(.paymentSuccess)
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }
}
