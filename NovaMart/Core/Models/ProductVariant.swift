import Foundation

struct ProductVariant: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var options: [String: String]
    var price: Decimal?
    var stock: Int
    var sku: String
    var imageIndex: Int?

    var isAvailable: Bool { stock > 0 }
    var isLowStock: Bool { stock > 0 && stock < 5 }

    var colorValue: String? { options["color"] }
    var sizeValue: String? { options["size"] }
    var materialValue: String? { options["material"] }
}
