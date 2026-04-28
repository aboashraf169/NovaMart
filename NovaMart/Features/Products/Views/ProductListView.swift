import SwiftUI

struct ProductListView: View {
    @Bindable var viewModel: ProductViewModel

    var body: some View {
        ScrollView {
            switch viewModel.viewState {
            case .loading, .idle:
                LoadingShimmer()
            case .loaded(let products):
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                        ProductListRow(product: product)
                            .staggeredAppear(index: index, delay: 0.04)
                            .onAppear {
                                if product.id == products.last?.id {
                                    Task { await viewModel.loadMore() }
                                }
                            }
                    }
                    if viewModel.isLoadingMore {
                        ProgressView().padding()
                    }
                }
                .padding(AppSpacing.screenPadding)
            case .empty:
                EmptyStateView(icon: "tray.fill", title: "No Products", message: "Try a different search.")
            case .error(let error):
                ErrorRetryView(error: error) { Task { await viewModel.load() } }
            }
        }
    }
}

struct ProductListRow: View {
    let product: Product
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            HStack(spacing: AppSpacing.md) {
                AsyncCachedImage(url: product.primaryImage?.url)
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(product.brand)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)

                    Text(product.name)
                        .font(AppTheme.Typography.labelMedium)
                        .lineLimit(2)
                        .foregroundStyle(.primary)

                    RatingStarsView(rating: product.rating, size: 11)

                    PriceView(price: product.price, compareAtPrice: product.compareAtPrice, size: .small)
                }

                Spacer()

                VStack(spacing: AppSpacing.sm) {
                    WishlistButton(productID: product.id)

                    Button {
                        appState.addToCart(product)
                    } label: {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                    .buttonStyle(ScalePressEffect())
                    .accessibilityLabel("Add to cart")
                }
            }
            .padding(AppSpacing.cardPadding)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}
