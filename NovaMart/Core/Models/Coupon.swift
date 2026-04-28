import Foundation

struct Coupon: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var code: String
    var type: CouponType
    var value: Decimal
    var minimumOrderAmount: Decimal?
    var usageLimit: Int?
    var usageLimitPerCustomer: Int?
    var usedCount: Int
    var expiresAt: Date?
    var isActive: Bool
    var description: String
    var createdAt: Date

    var isExpired: Bool {
        guard let exp = expiresAt else { return false }
        return exp < Date.now
    }

    var isValid: Bool { isActive && !isExpired }

    func discount(on amount: Decimal) -> Decimal {
        switch type {
        case .percentage:
            return amount * (value / 100)
        case .fixed:
            return min(value, amount)
        case .freeShipping:
            return 0
        }
    }

    static let samples: [Coupon] = [
        Coupon(id: UUID(), code: "SAVE20", type: .percentage, value: 20, minimumOrderAmount: 50, usageLimit: 1000, usageLimitPerCustomer: 1, usedCount: 432, expiresAt: Date.now.addingTimeInterval(86400 * 30), isActive: true, description: "20% off your order", createdAt: Date.now.addingTimeInterval(-86400 * 5)),
        Coupon(id: UUID(), code: "FLAT15", type: .fixed, value: 15, minimumOrderAmount: 75, usageLimit: nil, usageLimitPerCustomer: nil, usedCount: 87, expiresAt: nil, isActive: true, description: "$15 off orders over $75", createdAt: Date.now.addingTimeInterval(-86400 * 10)),
        Coupon(id: UUID(), code: "FREESHIP", type: .freeShipping, value: 0, minimumOrderAmount: nil, usageLimit: 500, usageLimitPerCustomer: 1, usedCount: 213, expiresAt: Date.now.addingTimeInterval(86400 * 7), isActive: true, description: "Free shipping on any order", createdAt: Date.now.addingTimeInterval(-86400 * 2))
    ]
}

enum CouponType: String, Codable, Sendable, CaseIterable {
    case percentage, fixed, freeShipping

    var displayName: String {
        switch self {
        case .percentage: "Percentage Off"
        case .fixed: "Fixed Amount"
        case .freeShipping: "Free Shipping"
        }
    }

    var icon: String {
        switch self {
        case .percentage: "percent"
        case .fixed: "dollarsign.circle.fill"
        case .freeShipping: "shippingbox.fill"
        }
    }
}
