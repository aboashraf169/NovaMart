import SwiftUI

struct WishlistView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = WishlistViewModel()

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading, .idle:
                GridShimmer(columns: 2)
            case .loaded(let items):
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: AppSpacing.gridSpacing), GridItem(.flexible(), spacing: AppSpacing.gridSpacing)],
                        spacing: AppSpacing.gridSpacing
                    ) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            WishlistItemCard(item: item, viewModel: viewModel)
                                .staggeredAppear(index: index, delay: 0.05)
                        }
                    }
                    .padding(AppSpacing.screenPadding)
                }
            case .empty:
                EmptyStateView(
                    icon: "heart.fill",
                    title: "Your Wishlist is Empty",
                    message: "Save products you love by tapping the heart icon.",
                    action: { appState.selectedTab = .home },
                    actionTitle: "Browse Products"
                )
            case .error(let error):
                ErrorRetryView(error: error) { Task { await viewModel.load(wishlistIDs: appState.wishlistIDs) } }
            }
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Wishlist")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: URL(string: "https://novamart.app/wishlist")!) {
                    Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.glass)
            }
        }
        .task { await viewModel.load(wishlistIDs: appState.wishlistIDs) }
        .onChange(of: appState.wishlistIDs) { _, ids in
            Task { await viewModel.load(wishlistIDs: ids) }
        }
    }
}

struct WishlistItemCard: View {
    let item: WishlistItem
    @Bindable var viewModel: WishlistViewModel
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationLink(destination: ProductDetailView(product: item.product)) {
                AsyncCachedImage(url: item.product.primaryImage?.url)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
            }
            .buttonStyle(.plain)

            // Overlay
            VStack(alignment: .leading, spacing: 4) {
                if item.hasPriceDropped, let drop = item.priceDrop {
                    GlassBadge(text: "↓ \(drop.formatted) drop!", color: AppTheme.Colors.success, size: .small)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(item.product.name)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        PriceView(price: item.product.price, compareAtPrice: nil, size: .small)
                    }

                    Spacer()

                    Button {
                        viewModel.moveToCart(item: item, appState: appState)
                    } label: {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .glassEffect(.regular.interactive(), in: .circle)
                    }
                    .buttonStyle(ScalePressEffect())
                }
            }
            .padding(AppSpacing.sm)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
            )
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.remove(itemID: item.id, appState: appState)
                HapticService.shared.play(.impact(.medium))
            } label: {
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(AppSpacing.xs)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.remove(itemID: item.id, appState: appState)
            } label: {
                Label("Remove", systemImage: "trash.fill")
            }

            Button {
                viewModel.moveToCart(item: item, appState: appState)
            } label: {
                Label("Add to Cart", systemImage: "bag.badge.plus")
            }
            .tint(AppTheme.Colors.primary)
        }
    }
}
