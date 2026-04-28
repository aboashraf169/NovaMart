import Foundation

extension Decimal {
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "$\(self)"
    }

    var formattedShort: String {
        let value = NSDecimalNumber(decimal: self).doubleValue
        switch value {
        case 1_000_000...:
            return String(format: "$%.1fM", value / 1_000_000)
        case 1_000...:
            return String(format: "$%.1fK", value / 1_000)
        default:
            return formatted
        }
    }
}

extension Double {
    var percentFormatted: String {
        let sign = self >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", self))%"
    }
}

extension Int {
    var compactFormatted: String {
        switch self {
        case 1_000_000...:
            return String(format: "%.1fM", Double(self) / 1_000_000)
        case 1_000...:
            return String(format: "%.1fK", Double(self) / 1_000)
        default:
            return "\(self)"
        }
    }
}
