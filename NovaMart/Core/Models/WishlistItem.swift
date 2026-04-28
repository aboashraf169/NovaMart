import Foundation

struct WishlistItem: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var product: Product
    var addedAt: Date
    var priceAlertEnabled: Bool
    var priceAtAdd: Decimal

    var hasPriceDropped: Bool {
        product.price < priceAtAdd
    }

    var priceDrop: Decimal? {
        guard hasPriceDropped else { return nil }
        return priceAtAdd - product.price
    }
}
