import SwiftUI

struct Product: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var longDescription: String
    var price: Decimal
    var compareAtPrice: Decimal?
    var costPrice: Decimal?
    var images: [ProductImage]
    var variants: [ProductVariant]
    var category: Category
    var tags: [String]
    var rating: Double
    var reviewCount: Int
    var soldCount: Int
    var stockQuantity: Int
    var sku: String
    var barcode: String?
    var weight: Double?
    var isFeatured: Bool
    var isActive: Bool
    var discountPercent: Int?
    var flashSaleEnds: Date?
    var brand: String
    var metaTitle: String?
    var metaDescription: String?
    var createdAt: Date
    var updatedAt: Date

    var isOnSale: Bool { compareAtPrice != nil }
    var isLowStock: Bool { stockQuantity > 0 && stockQuantity < 10 }
    var isOutOfStock: Bool { stockQuantity == 0 }
    var isFlashSale: Bool {
        guard let ends = flashSaleEnds else { return false }
        return ends > Date.now
    }

    var primaryImage: ProductImage? { images.first }

    var effectivePrice: Decimal {
        price
    }

    var savingsAmount: Decimal? {
        guard let compare = compareAtPrice else { return nil }
        return compare - price
    }

    var savingsPercent: Int? {
        guard let compare = compareAtPrice, compare > 0 else { return nil }
        let pct = (1.0 - NSDecimalNumber(decimal: price).doubleValue / NSDecimalNumber(decimal: compare).doubleValue) * 100
        return Int(pct.rounded())
    }

    static let samples: [Product] = Product.makeSamples()

    // MARK: - Samples
    static func makeSamples() -> [Product] {
        let categories = Category.allCategories
        return [
            Product(
                id: UUID(),
                name: "Pro Wireless Headphones",
                description: "Premium noise-cancelling headphones with 40hr battery",
                longDescription: "Experience audio perfection with our flagship wireless headphones. Featuring industry-leading active noise cancellation, 40 hours of battery life, and crystal-clear Hi-Res Audio certification. The premium memory foam ear cushions and lightweight aluminum frame ensure all-day comfort, while the advanced microphone array delivers studio-quality voice calls.",
                price: 299.99,
                compareAtPrice: 449.99,
                costPrice: 120.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800", altText: "Headphones front", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=800", altText: "Headphones side", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Midnight Black", options: ["color": "Black"], price: nil, stock: 15, sku: "HDX-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Pearl White", options: ["color": "White"], price: nil, stock: 8, sku: "HDX-WHT", imageIndex: 1),
                    ProductVariant(id: UUID(), name: "Midnight Blue", options: ["color": "Blue"], price: Decimal(319.99), stock: 3, sku: "HDX-BLU", imageIndex: nil)
                ],
                category: categories[0],
                tags: ["audio", "wireless", "premium"],
                rating: 4.8,
                reviewCount: 1247,
                soldCount: 8934,
                stockQuantity: 26,
                sku: "HDX-PRO",
                barcode: "0123456789012",
                weight: 0.28,
                isFeatured: true,
                isActive: true,
                discountPercent: 33,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 6),
                brand: "SoundCraft",
                metaTitle: "Pro Wireless Headphones - Best Noise Cancelling",
                metaDescription: "Shop premium wireless headphones with 40hr battery life and ANC.",
                createdAt: Date.now.addingTimeInterval(-86400 * 30),
                updatedAt: Date.now.addingTimeInterval(-3600)
            ),
            Product(
                id: UUID(),
                name: "Leather Crossbody Bag",
                description: "Handcrafted Italian leather with adjustable strap",
                longDescription: "Crafted from full-grain Italian leather, this versatile crossbody bag combines timeless elegance with modern functionality. The spacious interior features multiple compartments, RFID-blocking pockets, and a hidden security zipper. The adjustable 120cm strap allows for multiple carry styles.",
                price: 189.00,
                compareAtPrice: nil,
                costPrice: 65.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800", altText: "Leather bag", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Tan / One Size", options: ["color": "Tan", "size": "One Size"], price: nil, stock: 24, sku: "LCB-TAN", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Black / One Size", options: ["color": "Black", "size": "One Size"], price: nil, stock: 18, sku: "LCB-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Cognac / One Size", options: ["color": "Cognac", "size": "One Size"], price: nil, stock: 6, sku: "LCB-COG", imageIndex: 0)
                ],
                category: categories[1],
                tags: ["leather", "bag", "fashion"],
                rating: 4.6,
                reviewCount: 432,
                soldCount: 2156,
                stockQuantity: 48,
                sku: "LCB-001",
                barcode: nil,
                weight: 0.65,
                isFeatured: true,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "LuxLeather",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 60),
                updatedAt: Date.now.addingTimeInterval(-86400)
            ),
            Product(
                id: UUID(),
                name: "Smart Home Hub",
                description: "Control all your smart devices from one hub",
                longDescription: "The ultimate smart home controller with support for over 10,000 devices across all major platforms. Features a 7-inch touchscreen display, built-in voice assistant, and AI-powered automation routines that learn your habits over time.",
                price: 149.99,
                compareAtPrice: 199.99,
                costPrice: 60.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800", altText: "Smart home hub", sortOrder: 0)
                ],
                variants: [],
                category: categories[0],
                tags: ["smart home", "iot", "automation"],
                rating: 4.4,
                reviewCount: 678,
                soldCount: 3421,
                stockQuantity: 4,
                sku: "SHH-001",
                barcode: "0234567890123",
                weight: 0.45,
                isFeatured: false,
                isActive: true,
                discountPercent: 25,
                flashSaleEnds: nil,
                brand: "HomeTech",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 15),
                updatedAt: Date.now.addingTimeInterval(-7200)
            ),
            Product(
                id: UUID(),
                name: "Merino Wool Sweater",
                description: "Ultra-soft 100% merino wool, perfect for layering",
                longDescription: "Knitted from the finest 18.5 micron merino wool, this sweater offers exceptional softness, warmth without bulk, and natural moisture-wicking properties. The classic crew neck silhouette and ribbed cuffs ensure a timeless, versatile look that works equally well dressed up or down.",
                price: 125.00,
                compareAtPrice: nil,
                costPrice: 42.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800", altText: "Merino sweater", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Oat / XS", options: ["color": "Oat", "size": "XS"], price: nil, stock: 12, sku: "MWS-OAT-XS", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Oat / S", options: ["color": "Oat", "size": "S"], price: nil, stock: 18, sku: "MWS-OAT-S", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Oat / M", options: ["color": "Oat", "size": "M"], price: nil, stock: 22, sku: "MWS-OAT-M", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Oat / L", options: ["color": "Oat", "size": "L"], price: nil, stock: 15, sku: "MWS-OAT-L", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Forest / M", options: ["color": "Forest", "size": "M"], price: nil, stock: 9, sku: "MWS-FOR-M", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Navy / L", options: ["color": "Navy", "size": "L"], price: nil, stock: 0, sku: "MWS-NAV-L", imageIndex: 0)
                ],
                category: categories[1],
                tags: ["wool", "sweater", "winter"],
                rating: 4.9,
                reviewCount: 892,
                soldCount: 5674,
                stockQuantity: 76,
                sku: "MWS-001",
                barcode: nil,
                weight: 0.38,
                isFeatured: true,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "WoolWorks",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 90),
                updatedAt: Date.now.addingTimeInterval(-86400 * 2)
            ),
            Product(
                id: UUID(),
                name: "Yoga Mat Pro",
                description: "6mm eco-friendly mat with alignment marks",
                longDescription: "Crafted from natural tree rubber with a moisture-wicking microfiber top, this professional yoga mat provides superior grip whether your hands are dry or sweaty. The 6mm thickness cushions joints without compromising ground feel, and printed alignment lines help perfect your practice.",
                price: 78.00,
                compareAtPrice: 98.00,
                costPrice: 28.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800", altText: "Yoga mat", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Purple / Standard", options: ["color": "Purple", "size": "Standard"], price: nil, stock: 34, sku: "YMP-PUR", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Sage / Standard", options: ["color": "Sage", "size": "Standard"], price: nil, stock: 21, sku: "YMP-SAG", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Slate / Standard", options: ["color": "Slate", "size": "Standard"], price: nil, stock: 15, sku: "YMP-SLA", imageIndex: 0)
                ],
                category: categories[3],
                tags: ["yoga", "fitness", "eco"],
                rating: 4.7,
                reviewCount: 561,
                soldCount: 3892,
                stockQuantity: 70,
                sku: "YMP-001",
                barcode: nil,
                weight: 1.2,
                isFeatured: false,
                isActive: true,
                discountPercent: 20,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 12),
                brand: "EcoFlow",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 45),
                updatedAt: Date.now.addingTimeInterval(-3600 * 3)
            ),
            Product(
                id: UUID(),
                name: "Ceramic Pour-Over Set",
                description: "Handthrown ceramic dripper + carafe, serves 2",
                longDescription: "Each piece in this pour-over set is individually handthrown by master ceramicists, making every set truly unique. The specially designed dripper features multiple ridge lines for optimal flow rate, while the carafe's thick walls keep your coffee at the ideal serving temperature for over 45 minutes.",
                price: 89.00,
                compareAtPrice: nil,
                costPrice: 32.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800", altText: "Pour over coffee set", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Matte White", options: ["color": "Matte White"], price: nil, stock: 22, sku: "CPO-WHT", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Slate Grey", options: ["color": "Slate Grey"], price: nil, stock: 18, sku: "CPO-GRY", imageIndex: 0)
                ],
                category: categories[2],
                tags: ["coffee", "ceramic", "kitchen"],
                rating: 4.8,
                reviewCount: 234,
                soldCount: 1567,
                stockQuantity: 40,
                sku: "CPO-001",
                barcode: nil,
                weight: 0.85,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "CraftCeramics",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 20),
                updatedAt: Date.now.addingTimeInterval(-86400)
            )
        ]
    }
}

struct ProductImage: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var url: String
    var altText: String
    var sortOrder: Int
}
