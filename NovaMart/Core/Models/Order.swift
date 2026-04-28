import Foundation

struct Order: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var orderNumber: String
    var customer: OrderCustomer
    var items: [OrderItem]
    var status: OrderStatus
    var paymentStatus: PaymentStatus
    var subtotal: Decimal
    var discountAmount: Decimal
    var shippingCost: Decimal
    var taxAmount: Decimal
    var total: Decimal
    var couponCode: String?
    var shippingAddress: Address
    var billingAddress: Address
    var paymentMethod: PaymentMethod
    var trackingNumber: String?
    var estimatedDelivery: Date?
    var notes: String?
    var timeline: [OrderEvent]
    var createdAt: Date
    var updatedAt: Date

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    static let samples: [Order] = makeSamples()

    static func makeSamples() -> [Order] {
        let customer = OrderCustomer(id: UUID(), name: "Alex Johnson", email: "alex@example.com", phone: "+1 555-0100", avatarURL: nil)
        let address = Address.sample
        let method = PaymentMethod(id: UUID(), type: .applePay, last4: nil, brand: nil, expiryMonth: nil, expiryYear: nil, isDefault: true)

        return [
            Order(
                id: UUID(),
                orderNumber: "ORD-2026-00142",
                customer: customer,
                items: [
                    OrderItem(id: UUID(), product: Product.samples[0], variant: Product.samples[0].variants.first, quantity: 1, unitPrice: Product.samples[0].price, lineTotal: Product.samples[0].price)
                ],
                status: .outForDelivery,
                paymentStatus: .paid,
                subtotal: 299.99,
                discountAmount: 0,
                shippingCost: 0,
                taxAmount: 24.00,
                total: 323.99,
                couponCode: nil,
                shippingAddress: address,
                billingAddress: address,
                paymentMethod: method,
                trackingNumber: "1Z999AA10123456784",
                estimatedDelivery: Date.now.addingTimeInterval(3600 * 4),
                notes: nil,
                timeline: [
                    OrderEvent(id: UUID(), status: .confirmed, message: "Order confirmed", date: Date.now.addingTimeInterval(-86400 * 2)),
                    OrderEvent(id: UUID(), status: .processing, message: "Order being prepared", date: Date.now.addingTimeInterval(-86400)),
                    OrderEvent(id: UUID(), status: .shipped, message: "Package shipped via Express", date: Date.now.addingTimeInterval(-3600 * 12)),
                    OrderEvent(id: UUID(), status: .outForDelivery, message: "Out for delivery", date: Date.now.addingTimeInterval(-3600 * 2))
                ],
                createdAt: Date.now.addingTimeInterval(-86400 * 2),
                updatedAt: Date.now.addingTimeInterval(-3600 * 2)
            ),
            Order(
                id: UUID(),
                orderNumber: "ORD-2026-00138",
                customer: customer,
                items: [
                    OrderItem(id: UUID(), product: Product.samples[1], variant: Product.samples[1].variants.first, quantity: 1, unitPrice: Product.samples[1].price, lineTotal: Product.samples[1].price),
                    OrderItem(id: UUID(), product: Product.samples[3], variant: Product.samples[3].variants.first, quantity: 2, unitPrice: Product.samples[3].price, lineTotal: Product.samples[3].price * 2)
                ],
                status: .delivered,
                paymentStatus: .paid,
                subtotal: 439.00,
                discountAmount: 20.00,
                shippingCost: 8.99,
                taxAmount: 34.23,
                total: 462.22,
                couponCode: "SAVE20",
                shippingAddress: address,
                billingAddress: address,
                paymentMethod: method,
                trackingNumber: "1Z999AA10123456700",
                estimatedDelivery: Date.now.addingTimeInterval(-86400),
                notes: nil,
                timeline: [
                    OrderEvent(id: UUID(), status: .confirmed, message: "Order confirmed", date: Date.now.addingTimeInterval(-86400 * 7)),
                    OrderEvent(id: UUID(), status: .delivered, message: "Delivered to front door", date: Date.now.addingTimeInterval(-86400))
                ],
                createdAt: Date.now.addingTimeInterval(-86400 * 7),
                updatedAt: Date.now.addingTimeInterval(-86400)
            )
        ]
    }
}

struct OrderItem: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var product: Product
    var variant: ProductVariant?
    var quantity: Int
    var unitPrice: Decimal
    var lineTotal: Decimal
}

struct OrderEvent: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var status: OrderStatus
    var message: String
    var date: Date
    var location: String?
}
