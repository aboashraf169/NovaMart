import Foundation

struct Review: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var productID: UUID
    var author: ReviewAuthor
    var rating: Int
    var title: String
    var body: String
    var photoURLs: [String]
    var helpfulCount: Int
    var isVerifiedPurchase: Bool
    var createdAt: Date

    static let samples: [Review] = [
        Review(
            id: UUID(),
            productID: UUID(),
            author: ReviewAuthor(id: UUID(), name: "Sarah M.", avatarURL: nil),
            rating: 5,
            title: "Absolutely love these headphones",
            body: "The noise cancellation is incredible — I can work in a busy café and hear nothing but my music. Battery life is genuinely 38+ hours in my testing. Build quality feels premium.",
            photoURLs: [],
            helpfulCount: 124,
            isVerifiedPurchase: true,
            createdAt: Date.now.addingTimeInterval(-86400 * 10)
        ),
        Review(
            id: UUID(),
            productID: UUID(),
            author: ReviewAuthor(id: UUID(), name: "James K.", avatarURL: nil),
            rating: 4,
            title: "Great, but app needs work",
            body: "Sound quality is exceptional. The hardware is 5 stars. The companion app crashes occasionally on iOS 26, hence 4 stars. Will update when they fix it.",
            photoURLs: [],
            helpfulCount: 67,
            isVerifiedPurchase: true,
            createdAt: Date.now.addingTimeInterval(-86400 * 25)
        ),
        Review(
            id: UUID(),
            productID: UUID(),
            author: ReviewAuthor(id: UUID(), name: "Priya R.", avatarURL: nil),
            rating: 5,
            title: "Worth every penny",
            body: "Tried 6 different headphones this year. These are the best by a significant margin. The ear cups are supremely comfortable and the sound profile is perfectly balanced.",
            photoURLs: [],
            helpfulCount: 89,
            isVerifiedPurchase: true,
            createdAt: Date.now.addingTimeInterval(-86400 * 5)
        )
    ]
}

struct ReviewAuthor: Codable, Sendable, Hashable {
    let id: UUID
    var name: String
    var avatarURL: String?
}

struct ReviewHistogram: Sendable {
    var fiveStar: Int
    var fourStar: Int
    var threeStar: Int
    var twoStar: Int
    var oneStar: Int

    var total: Int { fiveStar + fourStar + threeStar + twoStar + oneStar }

    func fraction(for stars: Int) -> Double {
        guard total > 0 else { return 0 }
        let count: Int
        switch stars {
        case 5: count = fiveStar
        case 4: count = fourStar
        case 3: count = threeStar
        case 2: count = twoStar
        case 1: count = oneStar
        default: count = 0
        }
        return Double(count) / Double(total)
    }

    static let sample = ReviewHistogram(fiveStar: 890, fourStar: 245, threeStar: 78, twoStar: 22, oneStar: 12)
}
