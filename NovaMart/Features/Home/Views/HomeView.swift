import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HomeViewModel()
    @Namespace private var heroNamespace

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero — edge-to-edge, no padding
                HeroBannerView(products: viewModel.heroProducts, namespace: heroNamespace)

                VStack(spacing: AppSpacing.sectionSpacing) {
                    // Categories
                    CategoryScrollView(categories: viewModel.categories)
                        .padding(.top, AppSpacing.lg)

                    // Flash Sale — only when active
                    if let flashEnd = viewModel.flashSaleEndDate, !viewModel.flashSaleProducts.isEmpty {
                        FlashSaleView(products: viewModel.flashSaleProducts, endDate: flashEnd)
                    }

                    // Featured — clean even grid
                    if !viewModel.featuredProducts.isEmpty {
                        FeaturedCollectionView(products: viewModel.featuredProducts)
                    }

                    // Trending
                    if !viewModel.trendingProducts.isEmpty {
                        TrendingNowView(products: viewModel.trendingProducts)
                    }

                    // For You
                    if !viewModel.personalizedProducts.isEmpty {
                        PersonalizedSection(products: viewModel.personalizedProducts)
                    }

                    Spacer(minLength: AppSpacing.xxl)
                }
            }
        }
        .background(AnimatedMeshBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.selectedTab = .search
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.glass)
                .accessibilityLabel("Search")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NotificationBellButton()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.load()
        }
    }
}

struct NotificationBellButton: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(destination: NotificationCenterView()) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .semibold))

                if appState.notificationCount > 0 {
                    Circle()
                        .fill(AppTheme.Colors.accent)
                        .frame(width: 8, height: 8)
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.glass)
        .accessibilityLabel("Notifications, \(appState.notificationCount) unread")
    }
}
