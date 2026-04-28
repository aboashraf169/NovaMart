import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(Tab.home)

            NavigationStack {
                SearchView()
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(Tab.search)

            NavigationStack {
                WishlistView()
            }
            .tabItem { Label("Wishlist", systemImage: "heart.fill") }
            .tag(Tab.wishlist)
            .badge(appState.wishlistIDs.count > 0 ? appState.wishlistIDs.count : 0)

            NavigationStack {
                CartView()
            }
            .tabItem { Label("Cart", systemImage: "bag.fill") }
            .tag(Tab.cart)
            .badge(appState.cartItemCount > 0 ? appState.cartItemCount : 0)

            NavigationStack {
                OrderListView()
            }
            .tabItem { Label("Orders", systemImage: "list.bullet.rectangle") }
            .tag(Tab.orders)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.fill") }
            .tag(Tab.profile)
        }
        .onChange(of: appState.selectedTab) { _, _ in
            HapticService.shared.play(.selection)
        }
    }
}
