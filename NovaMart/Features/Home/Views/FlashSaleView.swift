import SwiftUI

struct FlashSaleView: View {
    let products: [Product]
    let endDate: Date

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Bold header strip
            HStack(alignment: .center) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.white)
                    Text("FLASH SALE")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(.white)
                }

                Spacer()

                CountdownTimer(endDate: endDate)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.sm)
            .background(AppTheme.Colors.accentGradient)

            // Product cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(products) { product in
                        FlashSaleCard(product: product)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xs)
            }
        }
    }
}

struct FlashSaleCard: View {
    let product: Product
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: 0) {
                // Image with discount badge
                ZStack(alignment: .topTrailing) {
                    AsyncCachedImage(url: product.primaryImage?.url) {
                        Rectangle().fill(Color(UIColor.systemGray5))
                    }
                    .frame(width: 150, height: 150)
                    .clipped()

                    if let pct = product.savingsPercent {
                        Text("-\(pct)%")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AppTheme.Colors.accent, in: Capsule())
                            .padding(AppSpacing.xs)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(product.name)
                        .font(AppTheme.Typography.labelSmall)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                        .frame(height: 34, alignment: .topLeading)

                    PriceView(price: product.price, compareAtPrice: product.compareAtPrice, size: .small)

                    Button {
                        appState.addToCart(product)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "bag.badge.plus")
                            Text("Add")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(AppTheme.Colors.primaryGradient, in: Capsule())
                    }
                    .buttonStyle(ScalePressEffect())
                }
                .padding(AppSpacing.sm)
            }
            .frame(width: 150)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

