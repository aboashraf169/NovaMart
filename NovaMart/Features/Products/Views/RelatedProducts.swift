import SwiftUI

struct RelatedProductsView: View {
    let productID: UUID
    @State private var products: [Product] = []

    var body: some View {
        Group {
            if !products.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("You Might Also Like")
                        .font(AppTheme.Typography.title3)
                        .padding(.horizontal, AppSpacing.screenPadding)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.md) {
                            ForEach(products) { product in
                                RelatedProductCard(product: product)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
            }
        }
        .task {
            do {
                products = try await ProductService.shared.fetchRelated(productID: productID)
            } catch {
                products = Array(Product.samples.filter { $0.id != productID }.prefix(5))
            }
        }
    }
}

struct RelatedProductCard: View {
    let product: Product
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ZStack(alignment: .topTrailing) {
                    AsyncCachedImage(url: product.primaryImage?.url)
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                    WishlistButton(productID: product.id)
                        .padding(AppSpacing.xs)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(AppTheme.Typography.labelSmall)
                        .lineLimit(2)
                        .foregroundStyle(.primary)

                    PriceView(price: product.price, compareAtPrice: product.compareAtPrice, size: .small)
                }
            }
            .frame(width: 140)
        }
        .buttonStyle(.plain)
    }
}
