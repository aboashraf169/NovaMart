import SwiftUI

struct User: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var avatarURL: String?
    var role: UserRole
    var loyaltyPoints: Int
    var loyaltyTier: LoyaltyTier
    var addresses: [Address]
    var defaultAddressID: UUID?
    var paymentMethods: [PaymentMethod]
    var defaultPaymentID: UUID?
    var notificationPreferences: NotificationPreferences
    var language: String
    var createdAt: Date
    var lastLoginAt: Date

    var defaultAddress: Address? {
        guard let id = defaultAddressID else { return addresses.first }
        return addresses.first { $0.id == id }
    }

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var tierProgress: Double {
        let current = loyaltyPoints
        let tierMin = loyaltyTier.pointsRequired
        let tierMax = loyaltyTier.nextTier?.pointsRequired ?? tierMin + 1
        guard tierMax > tierMin else { return 1.0 }
        return Double(current - tierMin) / Double(tierMax - tierMin)
    }
}

enum UserRole: String, Codable, Sendable {
    case customer, admin, staff
}

struct NotificationPreferences: Codable, Sendable, Hashable {
    var orderUpdates: Bool = true
    var promotions: Bool = true
    var priceDrops: Bool = true
    var newArrivals: Bool = false
    var systemAlerts: Bool = true
}

struct OrderCustomer: Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var avatarURL: String?
}
