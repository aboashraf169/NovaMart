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
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&auto=format&fit=crop", altText: "Leather bag", sortOrder: 0)
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
            ),
            Product(
                id: UUID(),
                name: "4K Ultra HD Smart TV 55\"",
                description: "55-inch QLED display with HDR10+ and built-in streaming",
                longDescription: "Immerse yourself in stunning 4K QLED picture quality with Quantum Dot technology that delivers over a billion colours. HDR10+ and Dolby Vision support ensures every scene looks exactly as the director intended. The built-in streaming platform gives you instant access to all your favourite apps, while the sleek bezel-less design complements any living room.",
                price: 799.99,
                compareAtPrice: 1099.99,
                costPrice: 380.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800", altText: "Smart TV", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1571415060716-baff5f717c94?w=800", altText: "TV display close up", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "55 inch", options: ["size": "55\""], price: nil, stock: 12, sku: "TV4K-55", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "65 inch", options: ["size": "65\""], price: Decimal(999.99), stock: 7, sku: "TV4K-65", imageIndex: 0)
                ],
                category: categories[0],
                tags: ["tv", "4k", "smart", "electronics"],
                rating: 4.6,
                reviewCount: 2341,
                soldCount: 4892,
                stockQuantity: 19,
                sku: "TV4K-001",
                barcode: "0345678901234",
                weight: 18.5,
                isFeatured: true,
                isActive: true,
                discountPercent: 27,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 8),
                brand: "VisionTech",
                metaTitle: "4K Smart TV - Best Picture Quality",
                metaDescription: "Shop 4K QLED Smart TV with HDR10+ and all streaming apps built in.",
                createdAt: Date.now.addingTimeInterval(-86400 * 10),
                updatedAt: Date.now.addingTimeInterval(-3600 * 2)
            ),
            Product(
                id: UUID(),
                name: "Running Shoes AirMax Pro",
                description: "Lightweight responsive foam with breathable knit upper",
                longDescription: "Engineered for performance runners, these shoes feature our latest ReactFoam midsole that returns 68% energy with every stride. The engineered knit upper wraps your foot for a sock-like fit while strategically placed ventilation zones keep feet cool on long runs. The rubber outsole offers superior grip on both road and light trail surfaces.",
                price: 145.00,
                compareAtPrice: 180.00,
                costPrice: 55.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800", altText: "Running shoes", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800", altText: "Running shoes side view", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "White / 40", options: ["color": "White", "size": "40"], price: nil, stock: 8, sku: "RSP-WHT-40", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "White / 41", options: ["color": "White", "size": "41"], price: nil, stock: 14, sku: "RSP-WHT-41", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "White / 42", options: ["color": "White", "size": "42"], price: nil, stock: 20, sku: "RSP-WHT-42", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Black / 41", options: ["color": "Black", "size": "41"], price: nil, stock: 11, sku: "RSP-BLK-41", imageIndex: 1),
                    ProductVariant(id: UUID(), name: "Black / 42", options: ["color": "Black", "size": "42"], price: nil, stock: 16, sku: "RSP-BLK-42", imageIndex: 1),
                    ProductVariant(id: UUID(), name: "Black / 43", options: ["color": "Black", "size": "43"], price: nil, stock: 9, sku: "RSP-BLK-43", imageIndex: 1)
                ],
                category: categories[3],
                tags: ["running", "shoes", "sports", "fitness"],
                rating: 4.7,
                reviewCount: 1834,
                soldCount: 9231,
                stockQuantity: 78,
                sku: "RSP-001",
                barcode: nil,
                weight: 0.32,
                isFeatured: true,
                isActive: true,
                discountPercent: 19,
                flashSaleEnds: nil,
                brand: "SpeedStep",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 55),
                updatedAt: Date.now.addingTimeInterval(-86400 * 3)
            ),
            Product(
                id: UUID(),
                name: "Vitamin C Brightening Serum",
                description: "15% L-ascorbic acid formula for radiant, even skin tone",
                longDescription: "Our award-winning serum combines 15% pure L-ascorbic acid with Vitamin E and ferulic acid for maximum stability and efficacy. This triple-action formula fades dark spots, boosts collagen production, and shields skin from environmental damage. Dermatologist-tested, fragrance-free, and suitable for all skin types. Results visible in as little as 4 weeks.",
                price: 58.00,
                compareAtPrice: nil,
                costPrice: 18.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1612817288484-6f916006741a?w=800", altText: "Vitamin C serum", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "30ml", options: ["size": "30ml"], price: nil, stock: 45, sku: "VCS-30", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "60ml", options: ["size": "60ml"], price: Decimal(98.00), stock: 30, sku: "VCS-60", imageIndex: 0)
                ],
                category: categories[4],
                tags: ["skincare", "serum", "vitamin c", "beauty"],
                rating: 4.9,
                reviewCount: 3124,
                soldCount: 18432,
                stockQuantity: 75,
                sku: "VCS-001",
                barcode: nil,
                weight: 0.12,
                isFeatured: true,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "GlowLab",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 120),
                updatedAt: Date.now.addingTimeInterval(-86400 * 1)
            ),
            Product(
                id: UUID(),
                name: "Stainless Steel Water Bottle",
                description: "Triple-insulated 1L bottle, keeps cold 48hr / hot 24hr",
                longDescription: "Built for adventure, this 1-litre stainless steel bottle uses triple-wall vacuum insulation to keep drinks cold for 48 hours or hot for 24. The leak-proof lid features a flip-top for one-handed drinking and a carabiner loop for clipping to bags. BPA-free, dishwasher-safe, and built to last a lifetime.",
                price: 42.00,
                compareAtPrice: 55.00,
                costPrice: 14.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1579736851738-a13e0d0b5fdf?w=800", altText: "Water bottle", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Midnight Black / 1L", options: ["color": "Black", "size": "1L"], price: nil, stock: 55, sku: "SSB-BLK-1L", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Ocean Blue / 1L", options: ["color": "Ocean Blue", "size": "1L"], price: nil, stock: 42, sku: "SSB-BLU-1L", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Forest Green / 1L", options: ["color": "Forest Green", "size": "1L"], price: nil, stock: 38, sku: "SSB-GRN-1L", imageIndex: 0)
                ],
                category: categories[3],
                tags: ["bottle", "hydration", "sports", "eco"],
                rating: 4.8,
                reviewCount: 4521,
                soldCount: 22341,
                stockQuantity: 135,
                sku: "SSB-001",
                barcode: nil,
                weight: 0.36,
                isFeatured: false,
                isActive: true,
                discountPercent: 24,
                flashSaleEnds: nil,
                brand: "HydroFlow",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 180),
                updatedAt: Date.now.addingTimeInterval(-86400 * 5)
            ),
            Product(
                id: UUID(),
                name: "Mechanical Keyboard TKL",
                description: "Tenkeyless layout with Cherry MX switches and RGB backlight",
                longDescription: "The ultimate typing experience for programmers and enthusiasts. This tenkeyless mechanical keyboard features genuine Cherry MX switches with satisfying tactile feedback, per-key RGB lighting with 16.8 million colours, and a full aluminium frame that weighs in at just 800g. Hot-swappable switches let you customise your feel without soldering.",
                price: 169.99,
                compareAtPrice: 219.99,
                costPrice: 65.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=800", altText: "Mechanical keyboard", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=800", altText: "Keyboard RGB backlight", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Brown Switch / Black", options: ["switch": "Brown", "color": "Black"], price: nil, stock: 18, sku: "MKB-BRN-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Red Switch / Black", options: ["switch": "Red", "color": "Black"], price: nil, stock: 14, sku: "MKB-RED-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Blue Switch / White", options: ["switch": "Blue", "color": "White"], price: nil, stock: 10, sku: "MKB-BLU-WHT", imageIndex: 1)
                ],
                category: categories[0],
                tags: ["keyboard", "mechanical", "gaming", "electronics"],
                rating: 4.7,
                reviewCount: 987,
                soldCount: 3452,
                stockQuantity: 42,
                sku: "MKB-001",
                barcode: "0456789012345",
                weight: 0.82,
                isFeatured: false,
                isActive: true,
                discountPercent: 23,
                flashSaleEnds: nil,
                brand: "TypeMaster",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 35),
                updatedAt: Date.now.addingTimeInterval(-3600 * 5)
            ),
            Product(
                id: UUID(),
                name: "Scented Soy Candle Set",
                description: "Set of 3 hand-poured soy candles, 40hr burn each",
                longDescription: "Our small-batch soy candles are hand-poured in small batches using 100% natural soy wax and cotton wicks. Each candle burns cleanly for up to 40 hours, filling your space with carefully crafted fragrance blends developed by perfumers. The set includes Cedarwood & Amber, Lavender & Sea Salt, and Vanilla & Sandalwood.",
                price: 54.00,
                compareAtPrice: nil,
                costPrice: 18.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1603905629-28674b48ed36?w=800", altText: "Soy candles", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "3-Pack Signature", options: ["set": "Signature"], price: nil, stock: 60, sku: "SCS-SIG", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "3-Pack Floral", options: ["set": "Floral"], price: nil, stock: 45, sku: "SCS-FLR", imageIndex: 0)
                ],
                category: categories[2],
                tags: ["candles", "home decor", "fragrance", "gift"],
                rating: 4.9,
                reviewCount: 1456,
                soldCount: 8923,
                stockQuantity: 105,
                sku: "SCS-001",
                barcode: nil,
                weight: 0.72,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "WaxPoetic",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 75),
                updatedAt: Date.now.addingTimeInterval(-86400 * 4)
            ),
            Product(
                id: UUID(),
                name: "Wireless Charging Pad Trio",
                description: "Charge phone, earbuds, and watch simultaneously",
                longDescription: "Stop juggling multiple chargers. This sleek 3-in-1 wireless charging pad simultaneously charges your smartphone (15W fast charge), wireless earbuds, and smartwatch. The low-profile design looks great on any desk or nightstand, and the LED indicator shows charging status at a glance. Compatible with all Qi-enabled devices.",
                price: 65.00,
                compareAtPrice: 89.00,
                costPrice: 22.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1616353071588-708dc5ab4f24?w=800", altText: "Wireless charger", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "White", options: ["color": "White"], price: nil, stock: 33, sku: "WCP-WHT", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Midnight", options: ["color": "Midnight"], price: nil, stock: 27, sku: "WCP-BLK", imageIndex: 0)
                ],
                category: categories[0],
                tags: ["charging", "wireless", "accessories", "electronics"],
                rating: 4.5,
                reviewCount: 762,
                soldCount: 5134,
                stockQuantity: 60,
                sku: "WCP-001",
                barcode: "0567890123456",
                weight: 0.19,
                isFeatured: false,
                isActive: true,
                discountPercent: 27,
                flashSaleEnds: nil,
                brand: "ChargeMate",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 25),
                updatedAt: Date.now.addingTimeInterval(-86400 * 2)
            ),
            Product(
                id: UUID(),
                name: "Denim Jacket Classic",
                description: "Washed denim jacket with vintage distressed finish",
                longDescription: "A wardrobe essential reimagined. Our classic denim jacket is crafted from 100% cotton denim with a stone-washed finish that only gets better with age. Featuring a slightly oversized silhouette, chest pockets, and adjustable button cuffs, this jacket pairs effortlessly with everything from dresses to joggers.",
                price: 98.00,
                compareAtPrice: nil,
                costPrice: 35.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?w=800", altText: "Denim jacket", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Light Wash / S", options: ["color": "Light Wash", "size": "S"], price: nil, stock: 15, sku: "DJC-LW-S", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Light Wash / M", options: ["color": "Light Wash", "size": "M"], price: nil, stock: 22, sku: "DJC-LW-M", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Light Wash / L", options: ["color": "Light Wash", "size": "L"], price: nil, stock: 18, sku: "DJC-LW-L", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Dark Wash / M", options: ["color": "Dark Wash", "size": "M"], price: nil, stock: 14, sku: "DJC-DW-M", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Dark Wash / L", options: ["color": "Dark Wash", "size": "L"], price: nil, stock: 11, sku: "DJC-DW-L", imageIndex: 0)
                ],
                category: categories[1],
                tags: ["denim", "jacket", "fashion", "casual"],
                rating: 4.6,
                reviewCount: 678,
                soldCount: 4231,
                stockQuantity: 80,
                sku: "DJC-001",
                barcode: nil,
                weight: 0.72,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "UrbanThread",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 40),
                updatedAt: Date.now.addingTimeInterval(-86400 * 6)
            ),
            Product(
                id: UUID(),
                name: "LEGO Architecture Skyline",
                description: "1,483-piece iconic city skyline building set for adults",
                longDescription: "Build and display one of the world's most iconic skylines with this premium LEGO Architecture set. The 1,483-piece set recreates famous landmarks in stunning detail and makes for an impressive display piece. Suitable for teens and adults, this set comes with a collector's booklet containing facts about each landmark and building techniques.",
                price: 119.99,
                compareAtPrice: nil,
                costPrice: 52.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=800", altText: "LEGO architecture set", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "New York", options: ["city": "New York"], price: nil, stock: 20, sku: "LAR-NYC", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Paris", options: ["city": "Paris"], price: nil, stock: 17, sku: "LAR-PAR", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Tokyo", options: ["city": "Tokyo"], price: nil, stock: 12, sku: "LAR-TKY", imageIndex: 0)
                ],
                category: categories[6],
                tags: ["lego", "toys", "building", "architecture"],
                rating: 4.8,
                reviewCount: 1123,
                soldCount: 6782,
                stockQuantity: 49,
                sku: "LAR-001",
                barcode: "0678901234567",
                weight: 1.45,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "BrickWorld",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 50),
                updatedAt: Date.now.addingTimeInterval(-86400 * 7)
            ),

            // ── Product 17 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Espresso Machine Pro",
                description: "15-bar pump espresso with built-in milk frother",
                longDescription: "Recreate café-quality espresso at home with our 15-bar pump machine. The thermoblock heating system reaches optimal temperature in under 30 seconds, while the professional steam wand lets you texture milk for lattes, cappuccinos, and flat whites. The removable 1.8L water tank and drip tray make maintenance effortless.",
                price: 249.00,
                compareAtPrice: 329.00,
                costPrice: 95.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1570286424717-86d8a0082d29?w=800", altText: "Espresso machine", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Silver", options: ["color": "Silver"], price: nil, stock: 18, sku: "ESP-SLV", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Matte Black", options: ["color": "Matte Black"], price: nil, stock: 12, sku: "ESP-BLK", imageIndex: 0)
                ],
                category: categories[2],
                tags: ["coffee", "espresso", "kitchen", "appliance"],
                rating: 4.7,
                reviewCount: 1893,
                soldCount: 7241,
                stockQuantity: 30,
                sku: "ESP-001",
                barcode: "0789012345678",
                weight: 3.2,
                isFeatured: true,
                isActive: true,
                discountPercent: 24,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 10),
                brand: "BrewMaster",
                metaTitle: "Pro Espresso Machine - Café Quality at Home",
                metaDescription: "15-bar espresso machine with steam wand for perfect lattes.",
                createdAt: Date.now.addingTimeInterval(-86400 * 18),
                updatedAt: Date.now.addingTimeInterval(-3600 * 4)
            ),

            // ── Product 18 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Polaroid Instant Camera",
                description: "Retro-style instant film camera with colour filters",
                longDescription: "Capture memories you can hold in your hands. This modern take on the classic instant camera prints credit-card-sized photos in seconds. It includes four colour filters, a selfie mirror, and a built-in flash that adjusts automatically. Compatible with i-Type and 600 film packs.",
                price: 89.99,
                compareAtPrice: nil,
                costPrice: 32.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800", altText: "Instant camera", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Dusky Pink", options: ["color": "Dusky Pink"], price: nil, stock: 25, sku: "POL-PNK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Cobalt Blue", options: ["color": "Cobalt Blue"], price: nil, stock: 20, sku: "POL-BLU", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Onyx Black", options: ["color": "Onyx Black"], price: nil, stock: 18, sku: "POL-BLK", imageIndex: 0)
                ],
                category: categories[0],
                tags: ["camera", "photography", "retro", "gift"],
                rating: 4.5,
                reviewCount: 2134,
                soldCount: 11203,
                stockQuantity: 63,
                sku: "POL-001",
                barcode: nil,
                weight: 0.35,
                isFeatured: true,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "SnapNow",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 65),
                updatedAt: Date.now.addingTimeInterval(-86400 * 3)
            ),

            // ── Product 19 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Bamboo Cutting Board Set",
                description: "Set of 3 organic bamboo boards with juice grooves",
                longDescription: "Made from sustainably sourced organic bamboo, this three-piece set covers every kitchen task. Each board features deep juice grooves to catch run-off, an easy-grip handle, and a non-slip base. Bamboo is naturally antimicrobial and harder than maple, yet gentler on knife edges.",
                price: 46.00,
                compareAtPrice: 62.00,
                costPrice: 15.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1585664811087-47f65abbad64?w=800", altText: "Bamboo cutting board", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "3-Piece Set", options: ["set": "3-piece"], price: nil, stock: 55, sku: "BCB-3PC", imageIndex: 0)
                ],
                category: categories[2],
                tags: ["kitchen", "bamboo", "eco", "cooking"],
                rating: 4.6,
                reviewCount: 3421,
                soldCount: 14892,
                stockQuantity: 55,
                sku: "BCB-001",
                barcode: nil,
                weight: 1.1,
                isFeatured: false,
                isActive: true,
                discountPercent: 26,
                flashSaleEnds: nil,
                brand: "EcoKitchen",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 110),
                updatedAt: Date.now.addingTimeInterval(-86400 * 8)
            ),

            // ── Product 20 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Resistance Band Kit",
                description: "5-level fabric bands with carry bag and workout guide",
                longDescription: "Level up any workout with our professional-grade fabric resistance bands. Unlike latex bands, the woven fabric won't roll, snap, or pinch skin. The set includes five progressive resistance levels from 5 to 35kg equivalent, a carry bag, and a 30-day workout guide for home or gym use.",
                price: 34.00,
                compareAtPrice: 48.00,
                costPrice: 10.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=800", altText: "Resistance bands", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "5-Band Set", options: ["set": "5-band"], price: nil, stock: 80, sku: "RBK-5PC", imageIndex: 0)
                ],
                category: categories[3],
                tags: ["fitness", "gym", "bands", "workout"],
                rating: 4.8,
                reviewCount: 5632,
                soldCount: 28341,
                stockQuantity: 80,
                sku: "RBK-001",
                barcode: nil,
                weight: 0.48,
                isFeatured: false,
                isActive: true,
                discountPercent: 29,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 14),
                brand: "FlexForce",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 200),
                updatedAt: Date.now.addingTimeInterval(-86400 * 1)
            ),

            // ── Product 21 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Linen Wide-Leg Trousers",
                description: "100% European linen, relaxed wide-leg fit",
                longDescription: "Cut from 100% European linen, these wide-leg trousers are the definition of effortless summer dressing. The natural fabric breathes beautifully, softening with every wash. A wide elasticated waistband, side pockets, and a versatile mid-rise sit make them as comfortable as they are stylish.",
                price: 88.00,
                compareAtPrice: nil,
                costPrice: 30.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1594938298603-c8148c4b4de5?w=800", altText: "Linen trousers", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Ecru / XS", options: ["color": "Ecru", "size": "XS"], price: nil, stock: 10, sku: "LWT-ECR-XS", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Ecru / S", options: ["color": "Ecru", "size": "S"], price: nil, stock: 18, sku: "LWT-ECR-S", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Ecru / M", options: ["color": "Ecru", "size": "M"], price: nil, stock: 22, sku: "LWT-ECR-M", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Terracotta / S", options: ["color": "Terracotta", "size": "S"], price: nil, stock: 14, sku: "LWT-TER-S", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Terracotta / M", options: ["color": "Terracotta", "size": "M"], price: nil, stock: 16, sku: "LWT-TER-M", imageIndex: 0)
                ],
                category: categories[1],
                tags: ["linen", "trousers", "fashion", "summer"],
                rating: 4.7,
                reviewCount: 743,
                soldCount: 3892,
                stockQuantity: 80,
                sku: "LWT-001",
                barcode: nil,
                weight: 0.28,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "LinenCo",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 28),
                updatedAt: Date.now.addingTimeInterval(-86400 * 4)
            ),

            // ── Product 22 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Noise-Cancelling Earbuds",
                description: "True wireless ANC earbuds, 32hr total playtime",
                longDescription: "Premium audio in a truly wireless package. These earbuds deliver active noise cancellation previously found only in over-ear headphones. With 8 hours per charge and a 24-hour charging case, you get 32 hours of ANC playback. The custom-tuned 10mm drivers produce rich bass and crystal highs.",
                price: 179.99,
                compareAtPrice: 239.99,
                costPrice: 68.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800", altText: "Wireless earbuds", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=800", altText: "Earbuds case", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Midnight Black", options: ["color": "Black"], price: nil, stock: 22, sku: "NCE-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Pearl White", options: ["color": "White"], price: nil, stock: 19, sku: "NCE-WHT", imageIndex: 1),
                    ProductVariant(id: UUID(), name: "Sage Green", options: ["color": "Sage"], price: nil, stock: 8, sku: "NCE-SGE", imageIndex: 0)
                ],
                category: categories[0],
                tags: ["earbuds", "audio", "wireless", "anc"],
                rating: 4.6,
                reviewCount: 3287,
                soldCount: 15432,
                stockQuantity: 49,
                sku: "NCE-001",
                barcode: "0890123456789",
                weight: 0.06,
                isFeatured: true,
                isActive: true,
                discountPercent: 25,
                flashSaleEnds: nil,
                brand: "SoundCraft",
                metaTitle: "Noise-Cancelling Earbuds - 32hr Battery",
                metaDescription: "True wireless ANC earbuds with premium sound and all-day battery.",
                createdAt: Date.now.addingTimeInterval(-86400 * 22),
                updatedAt: Date.now.addingTimeInterval(-3600 * 6)
            ),

            // ── Product 23 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Retinol Night Cream",
                description: "0.3% encapsulated retinol with hyaluronic acid",
                longDescription: "Our encapsulated retinol technology releases the active ingredient slowly through the night for maximum efficacy with minimal irritation. Combined with triple-weight hyaluronic acid for deep hydration and niacinamide to even skin tone, this cream visibly reduces fine lines and improves skin texture within 4 weeks.",
                price: 72.00,
                compareAtPrice: nil,
                costPrice: 22.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=800", altText: "Night cream", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "50ml", options: ["size": "50ml"], price: nil, stock: 60, sku: "RNC-50", imageIndex: 0)
                ],
                category: categories[4],
                tags: ["skincare", "retinol", "anti-aging", "beauty"],
                rating: 4.8,
                reviewCount: 2109,
                soldCount: 9832,
                stockQuantity: 60,
                sku: "RNC-001",
                barcode: nil,
                weight: 0.18,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "GlowLab",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 85),
                updatedAt: Date.now.addingTimeInterval(-86400 * 5)
            ),

            // ── Product 24 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Hardcover Notebook A5",
                description: "200-page dot-grid notebook with lay-flat binding",
                longDescription: "The perfect companion for notes, sketches, and bullet journaling. This A5 hardcover notebook features 200 pages of 120gsm ivory dot-grid paper that resists bleed-through even with fountain pens. The lay-flat sewn binding opens flat at any page, and the elastic closure and back pocket keep your notes secure.",
                price: 28.00,
                compareAtPrice: nil,
                costPrice: 8.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=800", altText: "Hardcover notebook", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Midnight Blue", options: ["color": "Midnight Blue"], price: nil, stock: 40, sku: "HCN-BLU", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Forest Green", options: ["color": "Forest Green"], price: nil, stock: 35, sku: "HCN-GRN", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Burgundy", options: ["color": "Burgundy"], price: nil, stock: 28, sku: "HCN-BUR", imageIndex: 0)
                ],
                category: categories[5],
                tags: ["notebook", "stationery", "books", "journaling"],
                rating: 4.9,
                reviewCount: 4532,
                soldCount: 21034,
                stockQuantity: 103,
                sku: "HCN-001",
                barcode: nil,
                weight: 0.32,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "PageCraft",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 150),
                updatedAt: Date.now.addingTimeInterval(-86400 * 10)
            ),

            // ── Product 25 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Car Dashboard Cam 4K",
                description: "4K front camera with night vision and GPS logging",
                longDescription: "Record every journey in stunning 4K clarity. The Sony STARVIS sensor delivers exceptional low-light footage, while built-in GPS logs your speed and location overlaid on the video. The 3-inch touchscreen makes reviewing footage simple, and the 140° wide-angle lens captures three lanes simultaneously. Supports up to 256GB microSD.",
                price: 139.99,
                compareAtPrice: 179.99,
                costPrice: 52.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1547036967-23d11aacaee0?w=800", altText: "Dash camera", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Front Only", options: ["type": "Front"], price: nil, stock: 30, sku: "DCM-FRT", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Front + Rear", options: ["type": "Front + Rear"], price: Decimal(189.99), stock: 20, sku: "DCM-F+R", imageIndex: 0)
                ],
                category: categories[7],
                tags: ["dashcam", "automotive", "camera", "safety"],
                rating: 4.6,
                reviewCount: 1432,
                soldCount: 6234,
                stockQuantity: 50,
                sku: "DCM-001",
                barcode: "0901234567890",
                weight: 0.19,
                isFeatured: false,
                isActive: true,
                discountPercent: 22,
                flashSaleEnds: nil,
                brand: "DriveSafe",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 32),
                updatedAt: Date.now.addingTimeInterval(-86400 * 2)
            ),

            // ── Product 26 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Silk Pillowcase Set",
                description: "22 momme mulberry silk, standard & queen size",
                longDescription: "Wake up with smoother skin and frizz-free hair. Our 22 momme mulberry silk pillowcases are the dermatologist-recommended grade for hair and skin care while you sleep. The silk's smooth surface reduces friction and moisture absorption, keeping your skin hydrated and your hair tangle-free. Each set includes two pillowcases.",
                price: 68.00,
                compareAtPrice: nil,
                costPrice: 22.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800", altText: "Silk pillowcase", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Ivory / Standard", options: ["color": "Ivory", "size": "Standard"], price: nil, stock: 30, sku: "SPC-IVR-STD", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Blush / Standard", options: ["color": "Blush", "size": "Standard"], price: nil, stock: 25, sku: "SPC-BLS-STD", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Midnight / Queen", options: ["color": "Midnight", "size": "Queen"], price: Decimal(78.00), stock: 20, sku: "SPC-MID-QN", imageIndex: 0)
                ],
                category: categories[2],
                tags: ["silk", "bedding", "beauty", "sleep"],
                rating: 4.9,
                reviewCount: 2876,
                soldCount: 13421,
                stockQuantity: 75,
                sku: "SPC-001",
                barcode: nil,
                weight: 0.22,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "SilkDream",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 70),
                updatedAt: Date.now.addingTimeInterval(-86400 * 6)
            ),

            // ── Product 27 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Portable Bluetooth Speaker",
                description: "360° sound, waterproof IPX7, 24hr battery",
                longDescription: "Take your music anywhere with this compact yet powerful 360° speaker. With 20W of output, dual passive radiators for deep bass, and IPX7 waterproofing, it thrives poolside, at the beach, or in the shower. The 24-hour battery and USB-C fast charging ensure it keeps up with your adventures.",
                price: 99.99,
                compareAtPrice: 129.99,
                costPrice: 36.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=800", altText: "Bluetooth speaker", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Stone Grey", options: ["color": "Stone Grey"], price: nil, stock: 28, sku: "PBS-GRY", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Teal", options: ["color": "Teal"], price: nil, stock: 22, sku: "PBS-TEL", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Coral", options: ["color": "Coral"], price: nil, stock: 15, sku: "PBS-CRL", imageIndex: 0)
                ],
                category: categories[0],
                tags: ["speaker", "audio", "bluetooth", "waterproof"],
                rating: 4.7,
                reviewCount: 4123,
                soldCount: 18932,
                stockQuantity: 65,
                sku: "PBS-001",
                barcode: "0012345678901",
                weight: 0.54,
                isFeatured: true,
                isActive: true,
                discountPercent: 23,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 7),
                brand: "SoundCraft",
                metaTitle: "Portable Bluetooth Speaker - Waterproof 360° Sound",
                metaDescription: "IPX7 waterproof Bluetooth speaker with 24-hour battery and deep bass.",
                createdAt: Date.now.addingTimeInterval(-86400 * 14),
                updatedAt: Date.now.addingTimeInterval(-3600 * 1)
            ),

            // ── Product 28 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Air Purifier HEPA H13",
                description: "Covers 60m², true HEPA H13 + activated carbon filter",
                longDescription: "Breathe cleaner air at home. This whisper-quiet air purifier covers up to 60 square metres and captures 99.97% of particles down to 0.3 microns, including dust, pollen, pet dander, and smoke. The activated carbon layer eliminates odours and VOCs. Auto mode adjusts fan speed based on real-time air quality sensor data.",
                price: 189.00,
                compareAtPrice: 249.00,
                costPrice: 72.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800", altText: "Air purifier", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "White", options: ["color": "White"], price: nil, stock: 16, sku: "APH-WHT", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Black", options: ["color": "Black"], price: nil, stock: 12, sku: "APH-BLK", imageIndex: 0)
                ],
                category: categories[2],
                tags: ["air purifier", "hepa", "home", "health"],
                rating: 4.8,
                reviewCount: 1654,
                soldCount: 7341,
                stockQuantity: 28,
                sku: "APH-001",
                barcode: "0123456789013",
                weight: 4.8,
                isFeatured: false,
                isActive: true,
                discountPercent: 24,
                flashSaleEnds: nil,
                brand: "PureAir",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 38),
                updatedAt: Date.now.addingTimeInterval(-86400 * 3)
            ),

            // ── Product 29 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Hiking Backpack 40L",
                description: "40L waterproof backpack with hip belt and hydration sleeve",
                longDescription: "Built for serious adventurers, this 40L backpack features a torso-adjustable suspension system that distributes weight between your shoulders and hips. The waterproof ripstop nylon shell keeps gear dry, while the hydration sleeve holds a 3L reservoir. Multiple access points, trekking pole loops, and a removable rain cover complete the package.",
                price: 165.00,
                compareAtPrice: nil,
                costPrice: 58.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=800", altText: "Hiking backpack", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Forest Green", options: ["color": "Forest Green"], price: nil, stock: 18, sku: "HBP-GRN", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Slate Grey", options: ["color": "Slate Grey"], price: nil, stock: 14, sku: "HBP-GRY", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Burnt Orange", options: ["color": "Burnt Orange"], price: nil, stock: 10, sku: "HBP-ORG", imageIndex: 0)
                ],
                category: categories[3],
                tags: ["backpack", "hiking", "outdoor", "travel"],
                rating: 4.8,
                reviewCount: 1234,
                soldCount: 5621,
                stockQuantity: 42,
                sku: "HBP-001",
                barcode: nil,
                weight: 1.35,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "TrailBlaze",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 42),
                updatedAt: Date.now.addingTimeInterval(-86400 * 5)
            ),

            // ── Product 31 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Smart Watch Series X",
                description: "AMOLED display, GPS, health tracking, 7-day battery",
                longDescription: "Stay connected and healthy with our flagship smartwatch. The always-on 1.4-inch AMOLED display is crisp in direct sunlight, while GPS, heart rate, SpO2, and sleep tracking keep you informed 24/7. With 7 days of battery life, 50m water resistance, and over 100 workout modes, this watch is built for every aspect of your life.",
                price: 329.00,
                compareAtPrice: 429.00,
                costPrice: 130.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800", altText: "Smart watch", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=800", altText: "Smart watch face", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Midnight Black / 44mm", options: ["color": "Black", "size": "44mm"], price: nil, stock: 20, sku: "SWX-BLK-44", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Silver / 44mm", options: ["color": "Silver", "size": "44mm"], price: nil, stock: 15, sku: "SWX-SLV-44", imageIndex: 1),
                    ProductVariant(id: UUID(), name: "Rose Gold / 40mm", options: ["color": "Rose Gold", "size": "40mm"], price: Decimal(309.00), stock: 12, sku: "SWX-RGD-40", imageIndex: 1)
                ],
                category: categories[0],
                tags: ["smartwatch", "fitness", "wearable", "electronics"],
                rating: 4.7,
                reviewCount: 2341,
                soldCount: 10234,
                stockQuantity: 47,
                sku: "SWX-001",
                barcode: "0123456700001",
                weight: 0.045,
                isFeatured: true,
                isActive: true,
                discountPercent: 23,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 5),
                brand: "TimeTech",
                metaTitle: "Smart Watch Series X - Health & GPS Tracking",
                metaDescription: "7-day battery smartwatch with AMOLED display, GPS, and comprehensive health monitoring.",
                createdAt: Date.now.addingTimeInterval(-86400 * 8),
                updatedAt: Date.now.addingTimeInterval(-3600 * 2)
            ),

            // ── Product 32 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Minimalist Leather Wallet",
                description: "Slim bi-fold wallet with RFID blocking, holds 8 cards",
                longDescription: "Slim down your carry with our minimalist bi-fold wallet crafted from full-grain vegetable-tanned leather. The RFID-blocking lining protects your contactless cards from skimming, while 8 card slots and a full-length cash section keep everything organised. The leather develops a rich patina over time, making each wallet unique.",
                price: 65.00,
                compareAtPrice: nil,
                costPrice: 20.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1627123424574-724758594e93?w=800", altText: "Leather wallet", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Tan", options: ["color": "Tan"], price: nil, stock: 40, sku: "MLW-TAN", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Black", options: ["color": "Black"], price: nil, stock: 35, sku: "MLW-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Dark Brown", options: ["color": "Dark Brown"], price: nil, stock: 28, sku: "MLW-DBR", imageIndex: 0)
                ],
                category: categories[1],
                tags: ["wallet", "leather", "rfid", "accessories"],
                rating: 4.8,
                reviewCount: 1876,
                soldCount: 9432,
                stockQuantity: 103,
                sku: "MLW-001",
                barcode: nil,
                weight: 0.08,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "LuxLeather",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 55),
                updatedAt: Date.now.addingTimeInterval(-86400 * 3)
            ),

            // ── Product 33 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Acne Facial Cleanser",
                description: "2% salicylic acid gel cleanser for clear skin",
                longDescription: "Formulated with 2% salicylic acid and niacinamide, this gentle yet effective gel cleanser unclogs pores, reduces blackheads, and calms redness without stripping the skin barrier. The low-pH formula is suitable for daily use on acne-prone, oily, and combination skin. Free from sulphates, parabens, and artificial fragrance.",
                price: 24.00,
                compareAtPrice: 32.00,
                costPrice: 7.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=800", altText: "Face cleanser", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "150ml", options: ["size": "150ml"], price: nil, stock: 80, sku: "AFC-150", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "300ml", options: ["size": "300ml"], price: Decimal(42.00), stock: 60, sku: "AFC-300", imageIndex: 0)
                ],
                category: categories[4],
                tags: ["skincare", "cleanser", "acne", "beauty"],
                rating: 4.7,
                reviewCount: 5234,
                soldCount: 31042,
                stockQuantity: 140,
                sku: "AFC-001",
                barcode: nil,
                weight: 0.19,
                isFeatured: false,
                isActive: true,
                discountPercent: 25,
                flashSaleEnds: nil,
                brand: "GlowLab",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 95),
                updatedAt: Date.now.addingTimeInterval(-86400 * 2)
            ),

            // ── Product 34 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Cast Iron Skillet 10\"",
                description: "Pre-seasoned cast iron pan, oven safe to 500°F",
                longDescription: "A kitchen workhorse that lasts generations. This 10-inch cast iron skillet comes factory pre-seasoned with flaxseed oil for a naturally non-stick surface that only improves with use. Equally at home on induction, gas, and electric hobs as it is in a 500°F oven or over a campfire. The helper handle makes it easy to manoeuvre.",
                price: 55.00,
                compareAtPrice: 72.00,
                costPrice: 20.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1591019478608-a43b5dc5c72c?w=800", altText: "Cast iron skillet", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "10 inch", options: ["size": "10\""], price: nil, stock: 35, sku: "CIS-10", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "12 inch", options: ["size": "12\""], price: Decimal(68.00), stock: 25, sku: "CIS-12", imageIndex: 0)
                ],
                category: categories[2],
                tags: ["cookware", "cast iron", "kitchen", "cooking"],
                rating: 4.9,
                reviewCount: 3421,
                soldCount: 15234,
                stockQuantity: 60,
                sku: "CIS-001",
                barcode: nil,
                weight: 2.5,
                isFeatured: false,
                isActive: true,
                discountPercent: 24,
                flashSaleEnds: nil,
                brand: "IronChef",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 130),
                updatedAt: Date.now.addingTimeInterval(-86400 * 7)
            ),

            // ── Product 35 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Gaming Headset RGB",
                description: "7.1 surround sound, noise-cancelling mic, memory foam",
                longDescription: "Gain a competitive edge with immersive 7.1 virtual surround sound that lets you hear every footstep. The unidirectional noise-cancelling microphone delivers crystal-clear voice communication, while memory foam ear cushions and an auto-adjusting headband ensure comfort during marathon sessions. The RGB lighting across 16.8 million colours adds the finishing touch.",
                price: 89.99,
                compareAtPrice: 119.99,
                costPrice: 34.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1599669454699-248893623440?w=800", altText: "Gaming headset", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1612444530582-fc66183b16f7?w=800", altText: "Gaming headset RGB", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Black / USB", options: ["color": "Black", "connection": "USB"], price: nil, stock: 25, sku: "GHS-BLK-USB", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "White / USB", options: ["color": "White", "connection": "USB"], price: nil, stock: 18, sku: "GHS-WHT-USB", imageIndex: 1),
                    ProductVariant(id: UUID(), name: "Black / 3.5mm", options: ["color": "Black", "connection": "3.5mm"], price: Decimal(79.99), stock: 20, sku: "GHS-BLK-35", imageIndex: 0)
                ],
                category: categories[0],
                tags: ["gaming", "headset", "rgb", "audio"],
                rating: 4.5,
                reviewCount: 1632,
                soldCount: 7234,
                stockQuantity: 63,
                sku: "GHS-001",
                barcode: "0123456700002",
                weight: 0.38,
                isFeatured: false,
                isActive: true,
                discountPercent: 25,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 9),
                brand: "GameZone",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 16),
                updatedAt: Date.now.addingTimeInterval(-3600 * 3)
            ),

            // ── Product 36 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Oversized Linen Shirt",
                description: "Relaxed-fit summer shirt in 100% stonewashed linen",
                longDescription: "The ultimate warm-weather essential. Cut in a relaxed, slightly oversized silhouette from 100% stonewashed European linen, this shirt softens with every wash and gets better with age. The dropped shoulders, chest pocket, and classic collar work equally well buttoned up or worn open over a t-shirt.",
                price: 72.00,
                compareAtPrice: nil,
                costPrice: 24.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800", altText: "Linen shirt", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "White / S", options: ["color": "White", "size": "S"], price: nil, stock: 18, sku: "OLS-WHT-S", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "White / M", options: ["color": "White", "size": "M"], price: nil, stock: 24, sku: "OLS-WHT-M", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "White / L", options: ["color": "White", "size": "L"], price: nil, stock: 20, sku: "OLS-WHT-L", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Sky Blue / M", options: ["color": "Sky Blue", "size": "M"], price: nil, stock: 16, sku: "OLS-BLU-M", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Sage / M", options: ["color": "Sage", "size": "M"], price: nil, stock: 14, sku: "OLS-SGE-M", imageIndex: 0)
                ],
                category: categories[1],
                tags: ["shirt", "linen", "summer", "fashion"],
                rating: 4.6,
                reviewCount: 892,
                soldCount: 4231,
                stockQuantity: 92,
                sku: "OLS-001",
                barcode: nil,
                weight: 0.22,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "LinenCo",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 22),
                updatedAt: Date.now.addingTimeInterval(-86400 * 2)
            ),

            // ── Product 37 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Foam Roller Pro",
                description: "High-density textured foam roller for deep-tissue massage",
                longDescription: "Recover faster and perform better with this professional-grade foam roller. The high-density EVA foam features a textured multi-zone surface that mimics a deep-tissue massage, targeting trigger points and releasing tight fascia. The hollow-core design makes it lightweight enough to take anywhere, while being firm enough to last years of daily use.",
                price: 38.00,
                compareAtPrice: 52.00,
                costPrice: 12.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800", altText: "Foam roller", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Black / Standard", options: ["color": "Black", "size": "Standard"], price: nil, stock: 50, sku: "FRP-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Blue / Standard", options: ["color": "Blue", "size": "Standard"], price: nil, stock: 40, sku: "FRP-BLU", imageIndex: 0)
                ],
                category: categories[3],
                tags: ["fitness", "recovery", "massage", "gym"],
                rating: 4.7,
                reviewCount: 2134,
                soldCount: 11234,
                stockQuantity: 90,
                sku: "FRP-001",
                barcode: nil,
                weight: 0.42,
                isFeatured: false,
                isActive: true,
                discountPercent: 27,
                flashSaleEnds: nil,
                brand: "FlexForce",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 68),
                updatedAt: Date.now.addingTimeInterval(-86400 * 4)
            ),

            // ── Product 38 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Wireless Ergonomic Mouse",
                description: "Vertical ergonomic design, 4000 DPI, 90-day battery",
                longDescription: "Eliminate wrist strain for good. The vertical design of this ergonomic mouse keeps your wrist in a natural handshake position, reducing muscle fatigue during long work sessions. With 2.4GHz wireless connection, adjustable DPI up to 4000, and a 90-day battery life on a single AA battery, it's the productivity upgrade your desk deserves.",
                price: 58.00,
                compareAtPrice: 78.00,
                costPrice: 20.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=800", altText: "Ergonomic mouse", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Black", options: ["color": "Black"], price: nil, stock: 30, sku: "WEM-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "White", options: ["color": "White"], price: nil, stock: 22, sku: "WEM-WHT", imageIndex: 0)
                ],
                category: categories[0],
                tags: ["mouse", "ergonomic", "wireless", "electronics"],
                rating: 4.6,
                reviewCount: 1432,
                soldCount: 6234,
                stockQuantity: 52,
                sku: "WEM-001",
                barcode: "0123456700003",
                weight: 0.13,
                isFeatured: false,
                isActive: true,
                discountPercent: 26,
                flashSaleEnds: nil,
                brand: "TypeMaster",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 45),
                updatedAt: Date.now.addingTimeInterval(-86400 * 5)
            ),

            // ── Product 39 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Sunscreen SPF 50+ Face Mist",
                description: "Invisible SPF 50+ mist for reapplication on the go",
                longDescription: "Reapplying sunscreen over makeup is now effortless. This ultra-fine mist delivers broad-spectrum SPF 50+ UVA/UVB protection in seconds without disturbing your makeup. The formula contains antioxidant vitamin E and soothing centella asiatica for added skin benefits. Water-resistant for up to 4 hours.",
                price: 32.00,
                compareAtPrice: nil,
                costPrice: 9.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=800", altText: "Sunscreen mist", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "100ml", options: ["size": "100ml"], price: nil, stock: 90, sku: "SSM-100", imageIndex: 0)
                ],
                category: categories[4],
                tags: ["sunscreen", "spf", "skincare", "beauty"],
                rating: 4.8,
                reviewCount: 3241,
                soldCount: 19034,
                stockQuantity: 90,
                sku: "SSM-001",
                barcode: nil,
                weight: 0.14,
                isFeatured: false,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "GlowLab",
                metaTitle: nil,
                metaDescription: nil,
                createdAt: Date.now.addingTimeInterval(-86400 * 40),
                updatedAt: Date.now.addingTimeInterval(-86400 * 1)
            ),

            // ── Product 40 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Scooter Electric Foldable",
                description: "350W motor, 25km range, max speed 25km/h, foldable frame",
                longDescription: "Commute smarter with this lightweight foldable electric scooter. The 350W brushless motor reaches 25km/h while the 36V/7.5Ah lithium battery delivers up to 25km of range on a single charge. Front and rear disc brakes, solid 8.5-inch tyres, and IP54 water resistance make it a safe, practical urban transport solution. Folds in 3 seconds.",
                price: 449.00,
                compareAtPrice: 599.00,
                costPrice: 175.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800", altText: "Electric scooter", sortOrder: 0),
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800", altText: "Scooter folded", sortOrder: 1)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Black", options: ["color": "Black"], price: nil, stock: 10, sku: "ESC-BLK", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "White", options: ["color": "White"], price: nil, stock: 8, sku: "ESC-WHT", imageIndex: 1)
                ],
                category: categories[7],
                tags: ["scooter", "electric", "transport", "outdoor"],
                rating: 4.5,
                reviewCount: 876,
                soldCount: 3421,
                stockQuantity: 18,
                sku: "ESC-001",
                barcode: "0123456700004",
                weight: 12.5,
                isFeatured: true,
                isActive: true,
                discountPercent: 25,
                flashSaleEnds: Date.now.addingTimeInterval(3600 * 11),
                brand: "UrbanRide",
                metaTitle: "Foldable Electric Scooter - 25km Range",
                metaDescription: "Lightweight foldable electric scooter with 350W motor and 25km range.",
                createdAt: Date.now.addingTimeInterval(-86400 * 7),
                updatedAt: Date.now.addingTimeInterval(-3600 * 5)
            ),

            // ── Product 30 ──────────────────────────────────────────────
            Product(
                id: UUID(),
                name: "Perfume Discovery Set",
                description: "8 × 8ml luxury fragrance samples in gift box",
                longDescription: "Find your signature scent without committing to a full bottle. This curated discovery set includes eight 8ml spray samples spanning fresh citrus, woody amber, floral, and oriental fragrance families — all housed in a premium magnetic gift box. Each vial includes a tasting card with fragrance notes and a redemption code towards a full-size bottle.",
                price: 79.00,
                compareAtPrice: nil,
                costPrice: 26.00,
                images: [
                    ProductImage(id: UUID(), url: "https://images.unsplash.com/photo-1541643600914-78b084683702?w=800", altText: "Perfume set", sortOrder: 0)
                ],
                variants: [
                    ProductVariant(id: UUID(), name: "Floral Edition", options: ["edition": "Floral"], price: nil, stock: 35, sku: "PDS-FLR", imageIndex: 0),
                    ProductVariant(id: UUID(), name: "Oriental Edition", options: ["edition": "Oriental"], price: nil, stock: 28, sku: "PDS-ORI", imageIndex: 0)
                ],
                category: categories[4],
                tags: ["perfume", "fragrance", "beauty", "gift"],
                rating: 4.9,
                reviewCount: 1876,
                soldCount: 8943,
                stockQuantity: 63,
                sku: "PDS-001",
                barcode: nil,
                weight: 0.28,
                isFeatured: true,
                isActive: true,
                discountPercent: nil,
                flashSaleEnds: nil,
                brand: "ScentHouse",
                metaTitle: "Perfume Discovery Set - 8 Luxury Samples",
                metaDescription: "Find your signature scent with 8 luxury fragrance samples in a gift box.",
                createdAt: Date.now.addingTimeInterval(-86400 * 12),
                updatedAt: Date.now.addingTimeInterval(-3600 * 8)
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
