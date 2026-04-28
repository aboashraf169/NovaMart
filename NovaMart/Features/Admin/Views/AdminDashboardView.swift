import SwiftUI

struct AdminDashboardView: View {
    @State private var viewModel = AdminViewModel()
    @State private var selectedTab = 0
    @Environment(AppState.self) private var appState
    @State private var showSignOutConfirm = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                AdminOverviewTab(viewModel: viewModel, onSignOut: { showSignOutConfirm = true })
            }
            .tabItem { Label("Overview", systemImage: "chart.bar.fill") }
            .tag(0)

            NavigationStack {
                ProductManagerView(viewModel: viewModel)
            }
            .tabItem { Label("Products", systemImage: "bag.fill") }
            .tag(1)

            NavigationStack {
                OrderManagerView(viewModel: viewModel)
            }
            .tabItem { Label("Orders", systemImage: "list.bullet.rectangle") }
            .tag(2)

            NavigationStack {
                CustomerListView()
            }
            .tabItem { Label("Customers", systemImage: "person.2.fill") }
            .tag(3)

            NavigationStack {
                CouponListView(viewModel: viewModel)
            }
            .tabItem { Label("Coupons", systemImage: "ticket.fill") }
            .tag(4)
        }
        .task { await viewModel.loadDashboard() }
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                appState.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct AdminOverviewTab: View {
    @Bindable var viewModel: AdminViewModel
    var onSignOut: () -> Void = {}

    var body: some View {
        ScrollView {
            switch viewModel.viewState {
            case .loading, .idle:
                LoadingShimmer()
            case .loaded(let stats):
                VStack(spacing: AppSpacing.lg) {
                    // Period picker
                    Picker("Period", selection: $viewModel.selectedPeriod) {
                        ForEach(DashboardPeriod.allCases, id: \.rawValue) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .onChange(of: viewModel.selectedPeriod) { _, _ in
                        Task { await viewModel.loadDashboard() }
                    }

                    StatsGridView(stats: stats)
                    RevenueChartView(stats: stats)
                    OrdersChartView(stats: stats)
                    OrderVolumeTrendView(stats: stats)
                    TopProductsView(stats: stats)
                    RecentActivityFeed(orders: viewModel.orders)

                    // Low stock alerts
                    if stats.lowStockCount > 0 {
                        LowStockAlert(count: stats.lowStockCount)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
                .padding(.vertical, AppSpacing.md)
            case .empty:
                EmptyStateView(icon: "chart.bar", title: "No Data", message: "No data available for this period.")
            case .error(let error):
                ErrorRetryView(error: error) { Task { await viewModel.loadDashboard() } }
            }
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await viewModel.loadDashboard() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onSignOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(AppTheme.Colors.error)
                }
            }
        }
    }
}

struct LowStockAlert: View {
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppTheme.Colors.warning)
            Text("\(count) products running low on stock")
                .font(AppTheme.Typography.bodySmall)
            Spacer()
            Text("View")
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(AppTheme.Colors.primary)
        }
        .padding(AppSpacing.cardPadding)
        .glassCard(tint: AppTheme.Colors.warning)
    }
}
