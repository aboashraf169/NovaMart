import SwiftUI
import Observation

@Observable
@MainActor
final class WishlistViewModel {
    var items: [WishlistItem] = []
    var viewState: ViewState<[WishlistItem]> = .idle

    func load(wishlistIDs: Set<UUID>) async {
        viewState = .loading
        try? await Task.sleep(for: .milliseconds(300))

        let products = Product.samples.filter { wishlistIDs.contains($0.id) }
        items = products.map { product in
            WishlistItem(
                id: UUID(),
                product: product,
                addedAt: Date.now.addingTimeInterval(-Double.random(in: 0...86400 * 7)),
                priceAlertEnabled: Bool.random(),
                priceAtAdd: product.compareAtPrice ?? product.price
            )
        }
        viewState = items.isEmpty ? .empty : .loaded(items)
    }

    func remove(itemID: UUID, appState: AppState) {
        if let item = items.first(where: { $0.id == itemID }) {
            appState.toggleWishlist(productID: item.product.id)
        }
        withAnimation(.smooth) {
            items.removeAll { $0.id == itemID }
            viewState = items.isEmpty ? .empty : .loaded(items)
        }
    }

    func moveToCart(item: WishlistItem, appState: AppState) {
        appState.addToCart(item.product)
        remove(itemID: item.id, appState: appState)
    }
}
