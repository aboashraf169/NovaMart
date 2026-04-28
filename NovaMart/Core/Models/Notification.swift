import SwiftUI

struct AppNotification: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var type: NotificationType
    var title: String
    var body: String
    var isRead: Bool
    var actionURL: String?
    var imageURL: String?
    var createdAt: Date

    static let samples: [AppNotification] = [
        AppNotification(id: UUID(), type: .order, title: "Your order is on its way!", body: "ORD-2026-00142 is out for delivery. Estimated arrival: Today 4-6 PM", isRead: false, actionURL: nil, imageURL: nil, createdAt: Date.now.addingTimeInterval(-3600)),
        AppNotification(id: UUID(), type: .promotion, title: "Flash Sale starts now 🔥", body: "Up to 40% off electronics. Only 6 hours left!", isRead: false, actionURL: nil, imageURL: nil, createdAt: Date.now.addingTimeInterval(-7200)),
        AppNotification(id: UUID(), type: .priceDrop, title: "Price drop alert", body: "Smart Home Hub you wishlisted just dropped to $149.99", isRead: true, actionURL: nil, imageURL: nil, createdAt: Date.now.addingTimeInterval(-86400)),
        AppNotification(id: UUID(), type: .system, title: "Welcome to NovaMart!", body: "Your account is all set. Start exploring thousands of products.", isRead: true, actionURL: nil, imageURL: nil, createdAt: Date.now.addingTimeInterval(-86400 * 3))
    ]
}

enum NotificationType: String, Codable, Sendable, CaseIterable {
    case order, promotion, priceDrop, newArrival, system, loyalty

    var displayName: String {
        switch self {
        case .order: "Orders"
        case .promotion: "Promotions"
        case .priceDrop: "Price Drops"
        case .newArrival: "New Arrivals"
        case .system: "System"
        case .loyalty: "Loyalty"
        }
    }

    var icon: String {
        switch self {
        case .order: "shippingbox.fill"
        case .promotion: "tag.fill"
        case .priceDrop: "arrow.down.circle.fill"
        case .newArrival: "sparkles"
        case .system: "bell.fill"
        case .loyalty: "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .order: AppTheme.Colors.secondary
        case .promotion: AppTheme.Colors.accent
        case .priceDrop: Color(hex: "#34C759")
        case .newArrival: AppTheme.Colors.primary
        case .system: Color(hex: "#8E8E93")
        case .loyalty: Color(hex: "#FFD700")
        }
    }
}
