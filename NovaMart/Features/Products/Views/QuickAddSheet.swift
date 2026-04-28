import SwiftUI

struct QuickAddSheet: View {
    let product: Product
    @Binding var isPresented: Bool
    @Environment(AppState.self) private var appState
    @State private var selectedVariant: ProductVariant? = nil
    @State private var quantity = 1

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Handle
            Capsule()
                .fill(Color(UIColor.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, AppSpacing.sm)

            // Product header
            HStack(spacing: AppSpacing.md) {
                AsyncCachedImage(url: product.primaryImage?.url)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(product.name)
                        .font(AppTheme.Typography.labelLarge)
                        .lineLimit(2)

                    PriceView(price: selectedVariant?.price ?? product.price, compareAtPrice: product.compareAtPrice, size: .medium)

                    if product.isLowStock {
                        Text("Only \(product.stockQuantity) left!")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.warning)
                    }
                }

                Spacer()
            }

            // Variants (compact)
            if !product.variants.isEmpty {
                VariantSelectorView(product: product, selectedVariant: $selectedVariant)
            }

            // Quantity
            QuantityStepper(quantity: $quantity, maxQuantity: selectedVariant?.stock ?? product.stockQuantity)

            // Actions
            HStack(spacing: AppSpacing.md) {
                Button {
                    appState.toggleWishlist(productID: product.id)
                } label: {
                    Image(systemName: appState.isWishlisted(product.id) ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(appState.isWishlisted(product.id) ? .red : .primary)
                        .frame(width: AppSpacing.buttonHeight, height: AppSpacing.buttonHeight)
                        .glassCard(cornerRadius: AppTheme.Radius.button)
                }
                .buttonStyle(ScalePressEffect())

                GlassButton("Add to Cart", icon: "bag.badge.plus") {
                    appState.addToCart(product, variant: selectedVariant, quantity: quantity)
                    isPresented = false
                }
            }
        }
        .padding(AppSpacing.screenPadding)
    }
}
