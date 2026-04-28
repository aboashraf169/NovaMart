import Foundation

protocol ReviewServiceProtocol: Sendable {
    func fetchReviews(productID: UUID, page: Int) async throws -> [Review]
    func submitReview(_ review: Review) async throws -> Review
    func markHelpful(reviewID: UUID) async throws
    func reportReview(reviewID: UUID, reason: String) async throws
}

struct ReviewService: ReviewServiceProtocol {
    func fetchReviews(productID: UUID, page: Int) async throws -> [Review] {
        try await Task.sleep(for: .milliseconds(500))
        return Review.samples
    }

    func submitReview(_ review: Review) async throws -> Review {
        try await Task.sleep(for: .seconds(1))
        return review
    }

    func markHelpful(reviewID: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }

    func reportReview(reviewID: UUID, reason: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
    }
}
