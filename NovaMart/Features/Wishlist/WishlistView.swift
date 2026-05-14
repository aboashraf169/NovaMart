import SwiftUI

struct WishlistView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = WishlistViewModel()

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading, .idle:
                List {
                    ForEach(0..<6, id: \.self) { _ in
                        WishlistRowShimmer()
                    }
                }
                .listStyle(.insetGrouped)

            case .loaded(let items):
                List {
                    ForEach(items) { item in
                        WishlistCardView(item: item, viewModel: viewModel)
                    }
                }
                .listStyle(.insetGrouped)

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
        .navigationTitle("Wishlist")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: URL(string: "https://novamart.app/wishlist")!) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .task { await viewModel.load(wishlistIDs: appState.wishlistIDs) }
        .onChange(of: appState.wishlistIDs) { _, ids in
            Task { await viewModel.load(wishlistIDs: ids) }
        }
    }
}

#Preview {
    NavigationStack {
        WishlistView()
    }
    .environment(AppState())
}

// MARK: - Shimmer Row

private struct WishlistRowShimmer: View {
    var body: some View {
        HStack(spacing: 12) {
            ShimmerBox(width: 90, height: 90, cornerRadius: 12)
            VStack(alignment: .leading, spacing: 8) {
                ShimmerBox(width: 100, height: 10, cornerRadius: 5)
                ShimmerBox(width: 160, height: 14, cornerRadius: 5)
                ShimmerBox(width: 80, height: 10, cornerRadius: 5)
                Spacer(minLength: 0)
                ShimmerBox(width: 60, height: 16, cornerRadius: 5)
            }
        }
        .frame(height: 90)
        .padding(.vertical, 4)
    }
}
