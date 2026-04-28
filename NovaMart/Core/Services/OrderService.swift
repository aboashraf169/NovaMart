import Foundation

protocol OrderServiceProtocol: Sendable {
    func fetchOrders(userID: UUID) async throws -> [Order]
    func fetchOrder(id: UUID) async throws -> Order
    func placeOrder(items: [CartItem], address: Address, paymentMethod: PaymentMethod) async throws -> Order
    func cancelOrder(id: UUID) async throws -> Order
    func requestReturn(orderID: UUID, reason: String, notes: String) async throws
    func trackOrder(id: UUID) async throws -> [OrderEvent]
}

struct OrderService: OrderServiceProtocol {
    func fetchOrders(userID: UUID) async throws -> [Order] {
        try await Task.sleep(for: .milliseconds(400))
        return Order.samples
    }

    func fetchOrder(id: UUID) async throws -> Order {
        try await Task.sleep(for: .milliseconds(300))
        guard let order = Order.samples.first(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        return order
    }

    func placeOrder(items: [CartItem], address: Address, paymentMethod: PaymentMethod) async throws -> Order {
        try await Task.sleep(for: .seconds(1.2))
        let subtotal = items.reduce(Decimal(0)) { $0 + $1.product.price * Decimal($1.quantity) }
        let shipping: Decimal = subtotal >= 50 ? 0 : Decimal(5.99)
        let tax = subtotal * Decimal(0.08)
        let order = Order(
            id: UUID(),
            orderNumber: "NM-\(Int.random(in: 100_000...999_999))",
            customer: OrderCustomer(id: UUID(), name: "Demo User", email: "demo@novamart.app", phone: nil, avatarURL: nil),
            items: items.map { OrderItem(id: UUID(), product: $0.product, variant: $0.variant, quantity: $0.quantity, unitPrice: $0.product.price, lineTotal: $0.product.price * Decimal($0.quantity)) },
            status: .confirmed,
            paymentStatus: .paid,
            subtotal: subtotal,
            discountAmount: 0,
            shippingCost: shipping,
            taxAmount: tax,
            total: subtotal + shipping + tax,
            couponCode: nil,
            shippingAddress: address,
            billingAddress: address,
            paymentMethod: paymentMethod,
            trackingNumber: nil,
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: Int.random(in: 3...7), to: Date.now),
            notes: nil,
            timeline: [OrderEvent(id: UUID(), status: .confirmed, message: "Order confirmed and payment received.", date: Date.now, location: nil)],
            createdAt: Date.now,
            updatedAt: Date.now
        )
        return order
    }

    func cancelOrder(id: UUID) async throws -> Order {
        try await Task.sleep(for: .milliseconds(600))
        guard let order = Order.samples.first(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        return order
    }

    func requestReturn(orderID: UUID, reason: String, notes: String) async throws {
        try await Task.sleep(for: .milliseconds(700))
    }

    func trackOrder(id: UUID) async throws -> [OrderEvent] {
        try await Task.sleep(for: .milliseconds(400))
        return Order.samples.first(where: { $0.id == id })?.timeline ?? []
    }
}
