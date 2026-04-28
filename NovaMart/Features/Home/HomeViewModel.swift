import SwiftUI
import Observation

@Observable
@MainActor
final class HomeViewModel {
    var heroProducts: [Product] = []
    var categories: [Category] = []
    var flashSaleProducts: [Product] = []
    var flashSaleEndDate: Date? = nil
    var featuredProducts: [Product] = []
    var trendingProducts: [Product] = []
    var personalizedProducts: [Product] = []
    var viewState: ViewState<Bool> = .idle

    private let service: ProductServiceProtocol

    init(service: ProductServiceProtocol = ProductService.shared) {
        self.service = service
    }

    func load() async {
        guard case .idle = viewState else { return }
        viewState = .loading

        do {
            let products = try await service.fetchProducts(page: 1, filter: nil)
            populate(with: products)
            viewState = .loaded(true)
        } catch {
            // Fall back to sample data
            populate(with: Product.samples)
            viewState = .loaded(true)
        }
    }

    func refresh() async {
        viewState = .idle
        await load()
    }

    private func populate(with products: [Product]) {
        categories = Category.allCategories
        heroProducts = Array(products.prefix(4))
        flashSaleProducts = products.filter { $0.isFlashSale }
        flashSaleEndDate = products.compactMap(\.flashSaleEnds).min()
        featuredProducts = products.filter { $0.isFeatured }
        trendingProducts = Array(products.sorted { $0.soldCount > $1.soldCount }.prefix(8))
        personalizedProducts = Array(products.shuffled().prefix(6))
    }
}
