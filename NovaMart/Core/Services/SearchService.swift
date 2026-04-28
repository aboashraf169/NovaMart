import Foundation

protocol SearchServiceProtocol: Sendable {
    func search(query: String, filter: SearchFilter) async throws -> [Product]
    func trending() async throws -> [String]
    func suggestions(for query: String) async throws -> [String]
    func recentSearches() -> [String]
    func saveSearch(_ query: String)
    func clearRecentSearches()
}

struct SearchService: SearchServiceProtocol {
    private let recentKey = "novamart.recentSearches"

    func search(query: String, filter: SearchFilter) async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(350))
        var results = Product.samples

        if !query.isEmpty {
            results = results.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.brand.localizedCaseInsensitiveContains(query) ||
                $0.category.name.localizedCaseInsensitiveContains(query)
            }
        }

        if let categoryID = filter.categoryID {
            results = results.filter { $0.category.id == categoryID }
        }

        if let minPrice = filter.minPrice {
            results = results.filter { $0.price >= minPrice }
        }
        if let maxPrice = filter.maxPrice {
            results = results.filter { $0.price <= maxPrice }
        }

        if filter.inStockOnly {
            results = results.filter { !$0.isOutOfStock }
        }

        if let minRating = filter.minRating {
            results = results.filter { $0.rating >= minRating }
        }

        results.sort { lhs, rhs in
            switch filter.sortOrder {
            case .featured: return lhs.isFeatured && !rhs.isFeatured
            case .newest: return lhs.createdAt > rhs.createdAt
            case .priceAsc: return lhs.price < rhs.price
            case .priceDesc: return lhs.price > rhs.price
            case .rating: return lhs.rating > rhs.rating
            case .bestSelling: return lhs.soldCount > rhs.soldCount
            }
        }

        return results
    }

    func trending() async throws -> [String] {
        ["Wireless Headphones", "Smart Watch", "Running Shoes", "Laptop Stand", "Bluetooth Speaker", "Yoga Mat", "Coffee Maker", "Air Fryer"]
    }

    func suggestions(for query: String) async throws -> [String] {
        guard !query.isEmpty else { return [] }
        let all = ["Wireless Headphones", "Wireless Earbuds", "Smart Watch", "Smart Home", "Running Shoes", "Running Shorts"]
        return all.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    func recentSearches() -> [String] {
        UserDefaults.standard.stringArray(forKey: recentKey) ?? []
    }

    func saveSearch(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var recents = recentSearches()
        recents.removeAll { $0.lowercased() == query.lowercased() }
        recents.insert(query, at: 0)
        UserDefaults.standard.set(Array(recents.prefix(10)), forKey: recentKey)
    }

    func clearRecentSearches() {
        UserDefaults.standard.removeObject(forKey: recentKey)
    }
}
