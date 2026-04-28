import SwiftUI
import Observation

@Observable
@MainActor
final class AdminViewModel {
    var stats: DashboardStats? = nil
    var products: [Product] = Product.samples
    var orders: [Order] = Order.samples
    var coupons: [Coupon] = Coupon.samples
    var selectedPeriod: DashboardPeriod = .month
    var viewState: ViewState<DashboardStats> = .idle
    var productSearch = ""
    var orderStatusFilter: OrderStatus? = nil

    func loadDashboard() async {
        viewState = .loading
        try? await Task.sleep(for: .milliseconds(600))
        stats = DashboardStats.sample
        viewState = .loaded(DashboardStats.sample)
    }

    var filteredProducts: [Product] {
        if productSearch.isEmpty { return products }
        return products.filter { $0.name.localizedCaseInsensitiveContains(productSearch) || $0.sku.localizedCaseInsensitiveContains(productSearch) }
    }

    var filteredOrders: [Order] {
        guard let status = orderStatusFilter else { return orders }
        return orders.filter { $0.status == status }
    }

    func toggleProductActive(_ product: Product) {
        if let idx = products.firstIndex(where: { $0.id == product.id }) {
            products[idx].isActive.toggle()
        }
    }

    func deleteProduct(_ product: Product) {
        products.removeAll { $0.id == product.id }
        HapticService.shared.play(.impact(.heavy))
    }

    func duplicateProduct(_ product: Product) {
        var copy = product
        copy = Product(
            id: UUID(), name: "\(product.name) (Copy)", description: product.description,
            longDescription: product.longDescription, price: product.price,
            compareAtPrice: product.compareAtPrice, costPrice: product.costPrice,
            images: product.images, variants: product.variants, category: product.category,
            tags: product.tags, rating: 0, reviewCount: 0, soldCount: 0,
            stockQuantity: product.stockQuantity, sku: "\(product.sku)-COPY",
            barcode: nil, weight: product.weight, isFeatured: false, isActive: false,
            discountPercent: nil, flashSaleEnds: nil, brand: product.brand,
            metaTitle: nil, metaDescription: nil,
            createdAt: Date.now, updatedAt: Date.now
        )
        products.append(copy)
        HapticService.shared.play(.notification(.success))
    }

    func updateOrderStatus(_ order: Order, status: OrderStatus) {
        if let idx = orders.firstIndex(where: { $0.id == order.id }) {
            orders[idx].status = status
        }
    }

    func deleteCoupon(_ coupon: Coupon) {
        coupons.removeAll { $0.id == coupon.id }
    }
}
