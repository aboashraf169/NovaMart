import Foundation

// MARK: - Protocol
protocol ProductServiceProtocol: Sendable {
    func fetchProducts(page: Int, filter: SearchFilter?) async throws -> [Product]
    func fetchProduct(id: UUID) async throws -> Product
    func fetchFeatured() async throws -> [Product]
    func fetchFlashSale() async throws -> [Product]
    func fetchRelated(productID: UUID) async throws -> [Product]
    func fetchReviews(productID: UUID, page: Int) async throws -> [Review]
    func search(query: String, page: Int) async throws -> [Product]
}

// MARK: - Implementation
final class ProductService: ProductServiceProtocol {
    static let shared = ProductService()
    private let network = NetworkService.shared

    private init() {}

    func fetchProducts(page: Int, filter: SearchFilter?) async throws -> [Product] {
        // In production: network call. For demo: return samples.
        try await Task.sleep(for: .milliseconds(400))
        return applyFilter(filter, to: Product.samples)
    }

    func fetchProduct(id: UUID) async throws -> Product {
        guard let product = Product.samples.first(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        return product
    }

    func fetchFeatured() async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(300))
        return Product.samples.filter { $0.isFeatured }
    }

    func fetchFlashSale() async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(300))
        return Product.samples.filter { $0.isFlashSale }
    }

    func fetchRelated(productID: UUID) async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(300))
        return Array(Product.samples.filter { $0.id != productID }.prefix(6))
    }

    func fetchReviews(productID: UUID, page: Int) async throws -> [Review] {
        try await Task.sleep(for: .milliseconds(300))
        return Review.samples
    }

    func search(query: String, page: Int) async throws -> [Product] {
        let lowercased = query.lowercased()
        return Product.samples.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.brand.lowercased().contains(lowercased) ||
            $0.tags.contains { $0.lowercased().contains(lowercased) }
        }
    }

    private func applyFilter(_ filter: SearchFilter?, to products: [Product]) -> [Product] {
        guard let filter else { return products }
        var result = products

        if let categoryID = filter.categoryID {
            result = result.filter { $0.category.id == categoryID }
        }
        if let min = filter.minPrice {
            result = result.filter { $0.price >= min }
        }
        if let max = filter.maxPrice {
            result = result.filter { $0.price <= max }
        }
        if let minRating = filter.minRating {
            result = result.filter { $0.rating >= minRating }
        }
        if filter.inStockOnly {
            result = result.filter { !$0.isOutOfStock }
        }
        if filter.onSaleOnly {
            result = result.filter { $0.isOnSale }
        }

        switch filter.sortOrder {
        case .featured: result = result.sorted { $0.isFeatured && !$1.isFeatured }
        case .newest: result = result.sorted { $0.createdAt > $1.createdAt }
        case .priceAsc: result = result.sorted { $0.price < $1.price }
        case .priceDesc: result = result.sorted { $0.price > $1.price }
        case .rating: result = result.sorted { $0.rating > $1.rating }
        case .bestSelling: result = result.sorted { $0.soldCount > $1.soldCount }
        }

        return result
    }
}
