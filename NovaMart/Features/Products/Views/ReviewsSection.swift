import SwiftUI

struct ReviewsSection: View {
    let productID: UUID
    let rating: Double
    let reviewCount: Int
    @State private var reviews: [Review] = []
    @State private var histogram = ReviewHistogram.sample
    @State private var isLoaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Reviews")
                    .font(AppTheme.Typography.title3)
                Spacer()
                if reviewCount > 3 {
                    NavigationLink("See All \(reviewCount)") {
                        AllReviewsView(productID: productID)
                    }
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.primary)
                }
            }

            // Summary
            HStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.xs) {
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .foregroundStyle(AppTheme.Colors.primary)

                    RatingStarsView(rating: rating, size: 16)

                    Text("\(reviewCount.compactFormatted) reviews")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 5) {
                    ForEach((1...5).reversed(), id: \.self) { stars in
                        HStack(spacing: AppSpacing.sm) {
                            Text("\(stars)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 10)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(UIColor.systemGray5))
                                        .frame(height: 6)
                                    Capsule()
                                        .fill(Color(hex: "#FFD700"))
                                        .frame(width: geo.size.width * histogram.fraction(for: stars), height: 6)
                                }
                            }
                            .frame(height: 6)

                            Text("\(Int(histogram.fraction(for: stars) * 100))%")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .frame(width: 28, alignment: .trailing)
                        }
                    }
                }
            }
            .padding(AppSpacing.cardPadding)
            .glassCard()

            // Review cards
            if isLoaded {
                ForEach(reviews.prefix(3)) { review in
                    ReviewCard(review: review)
                }
            } else {
                ForEach(0..<2, id: \.self) { _ in
                    ShimmerRow()
                }
            }
        }
        .task {
            reviews = Review.samples
            isLoaded = true
        }
    }
}

struct ReviewCard: View {
    let review: Review
    @State private var markedHelpful = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                // Avatar
                Circle()
                    .fill(AppTheme.Colors.primaryGradient)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(String(review.author.name.prefix(1)))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text(review.author.name)
                            .font(AppTheme.Typography.labelSmall)
                        if review.isVerifiedPurchase {
                            GlassBadge(text: "Verified", color: AppTheme.Colors.secondary, size: .small)
                        }
                    }
                    Text(review.createdAt.relativeFormatted)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                RatingStarsView(rating: Double(review.rating), size: 11)
            }

            Text(review.title)
                .font(AppTheme.Typography.labelMedium)

            Text(review.body)
                .font(AppTheme.Typography.bodySmall)
                .foregroundStyle(.secondary)
                .lineLimit(4)

            HStack {
                Button {
                    withAnimation(.bouncy) { markedHelpful.toggle() }
                    HapticService.shared.play(.impact(.light))
                } label: {
                    Label(
                        markedHelpful ? "Helpful (\(review.helpfulCount + 1))" : "Helpful (\(review.helpfulCount))",
                        systemImage: markedHelpful ? "hand.thumbsup.fill" : "hand.thumbsup"
                    )
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(markedHelpful ? AppTheme.Colors.primary : .secondary)
                }
                .buttonStyle(ScalePressEffect())
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

struct AllReviewsView: View {
    let productID: UUID
    @State private var reviews = Review.samples

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(reviews) { review in
                    ReviewCard(review: review)
                }
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.large)
    }
}
