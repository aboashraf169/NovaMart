import Foundation

struct SearchFilter: Codable, Sendable, Equatable {
    var query: String
    var categoryID: UUID?
    var minPrice: Decimal?
    var maxPrice: Decimal?
    var minRating: Double?
    var brands: [String]
    var tags: [String]
    var inStockOnly: Bool
    var onSaleOnly: Bool
    var sortOrder: SortOrder

    static let empty = SearchFilter(
        query: "",
        categoryID: nil,
        minPrice: nil,
        maxPrice: nil,
        minRating: nil,
        brands: [],
        tags: [],
        inStockOnly: false,
        onSaleOnly: false,
        sortOrder: .featured
    )

    var isActive: Bool {
        categoryID != nil ||
        minPrice != nil ||
        maxPrice != nil ||
        minRating != nil ||
        !brands.isEmpty ||
        !tags.isEmpty ||
        inStockOnly ||
        onSaleOnly ||
        sortOrder != .featured
    }

    var activeFilterCount: Int {
        var count = 0
        if categoryID != nil { count += 1 }
        if minPrice != nil || maxPrice != nil { count += 1 }
        if minRating != nil { count += 1 }
        if !brands.isEmpty { count += 1 }
        if inStockOnly { count += 1 }
        if onSaleOnly { count += 1 }
        return count
    }
}

enum SortOrder: String, Codable, CaseIterable, Sendable {
    case featured, newest, priceAsc, priceDesc, rating, bestSelling

    var displayName: String {
        switch self {
        case .featured: "Featured"
        case .newest: "Newest First"
        case .priceAsc: "Price: Low to High"
        case .priceDesc: "Price: High to Low"
        case .rating: "Highest Rated"
        case .bestSelling: "Best Selling"
        }
    }

    var icon: String {
        switch self {
        case .featured: "sparkles"
        case .newest: "clock.fill"
        case .priceAsc: "arrow.up.circle.fill"
        case .priceDesc: "arrow.down.circle.fill"
        case .rating: "star.fill"
        case .bestSelling: "flame.fill"
        }
    }
}
