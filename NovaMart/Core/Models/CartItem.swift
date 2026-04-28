import Foundation

struct CartItem: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var product: Product
    var variant: ProductVariant?
    var quantity: Int
    var addedAt: Date

    init(id: UUID = UUID(), product: Product, variant: ProductVariant? = nil, quantity: Int = 1, addedAt: Date = Date.now) {
        self.id = id
        self.product = product
        self.variant = variant
        self.quantity = quantity
        self.addedAt = addedAt
    }

    var unitPrice: Decimal {
        variant?.price ?? product.price
    }

    var lineTotal: Decimal {
        unitPrice * Decimal(quantity)
    }
}
