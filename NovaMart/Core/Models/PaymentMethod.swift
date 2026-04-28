import SwiftUI

struct PaymentMethod: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var type: PaymentType
    var last4: String?
    var brand: CardBrand?
    var expiryMonth: Int?
    var expiryYear: Int?
    var isDefault: Bool

    var displayName: String {
        switch type {
        case .applePay:
            return "Apple Pay"
        case .card:
            let b = brand?.displayName ?? "Card"
            let digits = last4.map { " •••• \($0)" } ?? ""
            return "\(b)\(digits)"
        case .payPal:
            return "PayPal"
        case .bankTransfer:
            return "Bank Transfer"
        }
    }

    var icon: String {
        switch type {
        case .applePay: "apple.logo"
        case .card: brand?.icon ?? "creditcard.fill"
        case .payPal: "p.circle.fill"
        case .bankTransfer: "building.columns.fill"
        }
    }

    var isExpired: Bool {
        guard type == .card,
              let month = expiryMonth,
              let year = expiryYear else { return false }
        let cal = Calendar.current
        let now = Date.now
        let currentYear = cal.component(.year, from: now)
        let currentMonth = cal.component(.month, from: now)
        return year < currentYear || (year == currentYear && month < currentMonth)
    }
}

enum PaymentType: String, Codable, Sendable {
    case applePay, card, payPal, bankTransfer
}

enum CardBrand: String, Codable, Sendable {
    case visa, mastercard, amex, discover

    var displayName: String {
        switch self {
        case .visa: "Visa"
        case .mastercard: "Mastercard"
        case .amex: "American Express"
        case .discover: "Discover"
        }
    }

    var icon: String {
        switch self {
        case .visa: "creditcard.fill"
        case .mastercard: "creditcard.fill"
        case .amex: "creditcard.fill"
        case .discover: "creditcard.fill"
        }
    }

    var color: Color {
        switch self {
        case .visa: Color(hex: "#1A1F71")
        case .mastercard: Color(hex: "#EB001B")
        case .amex: Color(hex: "#007BC1")
        case .discover: Color(hex: "#FF6600")
        }
    }
}
