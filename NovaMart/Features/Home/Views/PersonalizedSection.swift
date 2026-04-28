import SwiftUI

struct PersonalizedSection: View {
    let products: [Product]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Picked For You", action: nil)
                .padding(.horizontal, AppSpacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(products) { product in
                        PersonalizedCard(product: product)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.xs)
            }
        }
    }
}

private struct PersonalizedCard: View {
    let product: Product
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(value: product) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // Image with wishlist
                ZStack(alignment: .topTrailing) {
                    AsyncCachedImage(url: product.images.first?.url) {
                        Rectangle().fill(Color(UIColor.systemGray5))
                    }
                    .frame(width: 150, height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                    WishlistButton(productID: product.id)
                        .padding(6)
                }

                // Name
                Text(product.name)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .frame(width: 150, alignment: .leading)

                // Rating row
                HStack(spacing: 3) {
                    RatingStarsView(rating: product.rating)
                    Spacer()
                }
                .frame(width: 150)

                // Price
                PriceView(price: product.price, compareAtPrice: product.compareAtPrice, size: .small)
            }
            .frame(width: 150)
        }
        .buttonStyle(ScalePressEffect())
    }
}
