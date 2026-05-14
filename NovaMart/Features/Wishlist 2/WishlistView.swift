import SwiftUI

// MARK: - WishlistView

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
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
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
                ErrorRetryView(error: error) {
                    Task { await viewModel.load(wishlistIDs: appState.wishlistIDs) }
                }
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

// MARK: - WishlistItemCard



// MARK: - Preview

#Preview {
    @Previewable @State var vm = WishlistViewModel()
    let items: [WishlistItem] = Product.samples.prefix(6).map { p in
        WishlistItem(id: UUID(), product: p, addedAt: .now, priceAlertEnabled: true,
                     priceAtAdd: p.compareAtPrice ?? p.price)
    }
    NavigationStack {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(items) { item in
                    WishlistItemCard(item: item, viewModel: vm)
                }
            }
            .padding(16)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Wishlist")
        .navigationBarTitleDisplayMode(.large)
    }
    .environment(AppState())
}
