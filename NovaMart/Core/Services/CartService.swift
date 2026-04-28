import Foundation

protocol CartServiceProtocol: Sendable {
    func fetchCart() async throws -> [CartItem]
    func addItem(_ item: CartItem) async throws -> [CartItem]
    func removeItem(id: UUID) async throws -> [CartItem]
    func updateQuantity(itemID: UUID, quantity: Int) async throws -> [CartItem]
    func applyCoupon(_ code: String) async throws -> Coupon
    func clearCart() async throws
}

struct CartService: CartServiceProtocol {
    func fetchCart() async throws -> [CartItem] { [] }

    func addItem(_ item: CartItem) async throws -> [CartItem] {
        try await Task.sleep(for: .milliseconds(200))
        return [item]
    }

    func removeItem(id: UUID) async throws -> [CartItem] {
        try await Task.sleep(for: .milliseconds(200))
        return []
    }

    func updateQuantity(itemID: UUID, quantity: Int) async throws -> [CartItem] {
        try await Task.sleep(for: .milliseconds(200))
        return []
    }

    func applyCoupon(_ code: String) async throws -> Coupon {
        try await Task.sleep(for: .milliseconds(800))
        guard let coupon = Coupon.samples.first(where: { $0.code == code.uppercased() && $0.isValid }) else {
            throw AppError.validation(ValidationError(message: "Coupon code not found or expired."))
        }
        return coupon
    }

    func clearCart() async throws {
        try await Task.sleep(for: .milliseconds(100))
    }
}
