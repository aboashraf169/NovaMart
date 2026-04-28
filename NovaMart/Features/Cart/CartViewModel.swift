import SwiftUI
import Observation

@Observable
@MainActor
final class CartViewModel {
    var appliedCoupon: Coupon? = nil
    var couponCode: String = ""
    var couponError: String? = nil
    var isValidatingCoupon = false
    var showCouponSuccess = false

    func validateCoupon(appState: AppState) async {
        let code = couponCode.trimmingCharacters(in: .whitespaces).uppercased()
        guard !code.isEmpty else { return }

        isValidatingCoupon = true
        defer { isValidatingCoupon = false }
        couponError = nil

        // Simulate validation
        try? await Task.sleep(for: .milliseconds(600))

        if let coupon = Coupon.samples.first(where: { $0.code == code && $0.isValid }) {
            if let minOrder = coupon.minimumOrderAmount, appState.cartTotal < minOrder {
                couponError = "Minimum order of \(minOrder.formatted) required for this coupon."
                HapticService.shared.play(.notification(.error))
            } else {
                appliedCoupon = coupon
                withAnimation(.bouncy) { showCouponSuccess = true }
                HapticService.shared.play(.notification(.success))
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    showCouponSuccess = false
                }
            }
        } else {
            couponError = "Invalid or expired coupon code."
            HapticService.shared.play(.notification(.error))
        }
    }

    func removeCoupon() {
        appliedCoupon = nil
        couponCode = ""
        couponError = nil
        HapticService.shared.play(.impact(.light))
    }

    func discount(on total: Decimal) -> Decimal {
        appliedCoupon?.discount(on: total) ?? 0
    }

    func shippingCost(subtotal: Decimal) -> Decimal {
        if appliedCoupon?.type == .freeShipping { return 0 }
        return subtotal >= 75 ? 0 : 8.99
    }

    func total(for appState: AppState) -> Decimal {
        let subtotal = appState.cartTotal
        let discount = self.discount(on: subtotal)
        let shipping = shippingCost(subtotal: subtotal)
        let tax = (subtotal - discount + shipping) * 0.08
        return subtotal - discount + shipping + tax
    }
}
