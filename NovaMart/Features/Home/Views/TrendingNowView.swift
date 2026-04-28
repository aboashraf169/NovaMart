import SwiftUI

struct TrendingNowView: View {
    let products: [Product]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Trending", action: nil)
                .padding(.horizontal, AppSpacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(Array(products.prefix(6).enumerated()), id: \.element.id) { index, product in
                        TrendingCard(product: product, rank: index + 1)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }
}

private struct TrendingCard: View {
    let product: Product
    let rank: Int

    var rankColor: Color {
        switch rank {
        case 1: AppTheme.Colors.accent
        case 2: AppTheme.Colors.warning
        case 3: AppTheme.Colors.secondary
        default: Color(UIColor.tertiaryLabel)
        }
    }

    var body: some View {
        NavigationLink(value: product) {
            ZStack(alignment: .topLeading) {
                // Image
                AsyncCachedImage(url: product.images.first?.url) {
                    Rectangle().fill(Color(UIColor.systemGray5))
                }
                .frame(width: 140, height: 175)
                .clipped()
                .allowsHitTesting(false)

                // Scrim
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.45),
                        .init(color: .black.opacity(0.75), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                // Rank badge — top-left corner
                Text("#\(rank)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(rankColor)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                    .padding(AppSpacing.sm)

                // Product info — bottom
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    Text(product.name)
                        .font(AppTheme.Typography.captionBold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(product.price.formatted)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(rankColor)
                }
                .padding(AppSpacing.sm)
                .frame(width: 140, alignment: .leading)
            }
            .frame(width: 140, height: 175)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        }
        .buttonStyle(ScalePressEffect())
    }
}
