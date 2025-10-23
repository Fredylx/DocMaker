import Foundation

struct StripeTestPaymentReceipt: Identifiable, Equatable {
    let id = UUID()
    let amount: Decimal
    let currency: String
    let confirmationCode: String
    let last4: String
    let createdAt: Date

    var formattedAmount: String {
        StripePaymentService.currencyFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(currency) \(amount)"
    }

    var formattedDate: String {
        StripePaymentService.dateFormatter.string(from: createdAt)
    }
}

protocol StripePaymentServicing {
    @MainActor
    func authorizeTestPayment(amount: Decimal, currency: String) async throws -> StripeTestPaymentReceipt
}

@MainActor
final class StripePaymentService: StripePaymentServicing {
    static let shared = StripePaymentService()

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private struct Constants {
        static let simulatedAuthorizationDelay: UInt64 = 1_200_000_000 // 1.2 seconds
    }

    func authorizeTestPayment(amount: Decimal, currency: String) async throws -> StripeTestPaymentReceipt {
        guard amount > 0 else { throw StripePaymentError.invalidAmount }

        Self.currencyFormatter.currencyCode = currency
        try await Task.sleep(nanoseconds: Constants.simulatedAuthorizationDelay)

        return StripeTestPaymentReceipt(
            amount: amount,
            currency: currency,
            confirmationCode: Self.generateConfirmationCode(),
            last4: "4242",
            createdAt: Date()
        )
    }

    private static func generateConfirmationCode() -> String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(12).uppercased()
    }
}

enum StripePaymentError: LocalizedError {
    case invalidAmount
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "The payment amount must be greater than zero."
        case .cancelled:
            return "The payment was cancelled."
        }
    }
}
