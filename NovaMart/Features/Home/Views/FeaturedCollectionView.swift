import SwiftUI

struct FeaturedCollectionView: View {
    let products: [Product]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Featured", action: nil)
                .padding(.horizontal, AppSpacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(Array(products.prefix(6).enumerated()), id: \.element.id) { index, product in
                        FeaturedCard(product: product)
                            .staggeredAppear(index: index, delay: 0.06)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Featured Card
private struct FeaturedCard: View {
    let product: Product
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .topTrailing) {
                    AsyncCachedImage(url: product.primaryImage?.url) {
                        Rectangle().fill(Color(UIColor.systemGray6))
                    }
                    .frame(width: 160, height: 160)
                    .clipped()

                    WishlistButton(productID: product.id)
                        .padding(6)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    RatingStarsView(rating: product.rating, size: 11)

                    PriceView(price: product.price, compareAtPrice: product.compareAtPrice, size: .small)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .frame(width: 160, alignment: .leading)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}


