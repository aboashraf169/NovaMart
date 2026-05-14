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

        // 1. Hero — featured products (up to 6)
        let featured = products.filter { $0.isFeatured }
        heroProducts = Array(featured.prefix(6))
        let heroIDs = Set(heroProducts.map(\.id))

        // 2. Flash sale — active deals, excluding hero
        flashSaleProducts = products.filter { $0.isFlashSale && !heroIDs.contains($0.id) }
        flashSaleEndDate = products.compactMap(\.flashSaleEnds).min()
        let flashIDs = Set(flashSaleProducts.map(\.id))

        // 3. Featured collection — remaining featured not already in hero
        featuredProducts = featured.filter { !heroIDs.contains($0.id) }
        let featuredIDs = Set(featuredProducts.map(\.id))

        // 4. Trending — top sellers excluding above sections
        let usedIDs = heroIDs.union(flashIDs).union(featuredIDs)
        trendingProducts = Array(
            products
                .filter { !usedIDs.contains($0.id) }
                .sorted { $0.soldCount > $1.soldCount }
                .prefix(8)
        )
        let trendingIDs = Set(trendingProducts.map(\.id))

        // 5. Picked For You — remaining products not shown anywhere else
        let allUsedIDs = usedIDs.union(trendingIDs)
        personalizedProducts = Array(
            products
                .filter { !allUsedIDs.contains($0.id) }
                .shuffled()
                .prefix(8)
        )
    }
}
