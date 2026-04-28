import SwiftUI

struct Category: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var slug: String
    var iconName: String
    var imageURL: String?
    var color: String
    var productCount: Int
    var parentID: UUID?
    var children: [Category]?
    var sortOrder: Int

    var swiftUIColor: Color {
        Color(hex: color)
    }

    static let allCategories: [Category] = [
        Category(id: UUID(), name: "Electronics", slug: "electronics", iconName: "laptopcomputer", imageURL: nil, color: "#6E3AFF", productCount: 124, parentID: nil, children: nil, sortOrder: 0),
        Category(id: UUID(), name: "Fashion", slug: "fashion", iconName: "tshirt.fill", imageURL: nil, color: "#FF6B35", productCount: 312, parentID: nil, children: nil, sortOrder: 1),
        Category(id: UUID(), name: "Home", slug: "home", iconName: "house.fill", imageURL: nil, color: "#00D4AA", productCount: 87, parentID: nil, children: nil, sortOrder: 2),
        Category(id: UUID(), name: "Sports", slug: "sports", iconName: "figure.run", imageURL: nil, color: "#34C759", productCount: 156, parentID: nil, children: nil, sortOrder: 3),
        Category(id: UUID(), name: "Beauty", slug: "beauty", iconName: "sparkles", imageURL: nil, color: "#FF2D55", productCount: 201, parentID: nil, children: nil, sortOrder: 4),
        Category(id: UUID(), name: "Books", slug: "books", iconName: "books.vertical.fill", imageURL: nil, color: "#FFCC00", productCount: 445, parentID: nil, children: nil, sortOrder: 5),
        Category(id: UUID(), name: "Toys", slug: "toys", iconName: "gamecontroller.fill", imageURL: nil, color: "#5AC8FA", productCount: 93, parentID: nil, children: nil, sortOrder: 6),
        Category(id: UUID(), name: "Automotive", slug: "automotive", iconName: "car.fill", imageURL: nil, color: "#FF9500", productCount: 68, parentID: nil, children: nil, sortOrder: 7)
    ]
}
