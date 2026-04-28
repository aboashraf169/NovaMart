import SwiftUI

struct OrderListView: View {
    @State private var viewModel = OrderViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        OrderStatusChip(
                            label: "All",
                            isSelected: viewModel.selectedStatus == nil
                        ) {
                            Task { await viewModel.filterByStatus(nil) }
                        }

                        ForEach([OrderStatus.pending, .processing, .shipped, .delivered, .cancelled], id: \.rawValue) { status in
                            OrderStatusChip(
                                label: status.displayName,
                                color: status.color,
                                isSelected: viewModel.selectedStatus == status
                            ) {
                                Task { await viewModel.filterByStatus(status) }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Orders
                switch viewModel.viewState {
                case .loading, .idle:
                    LoadingShimmer()
                case .loaded(let orders):
                    ForEach(orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderListCard(order: order)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .staggeredAppear(index: 0)
                    }
                case .empty:
                    EmptyStateView(
                        icon: "bag.fill",
                        title: "No Orders",
                        message: "Your orders will appear here.",
                        action: nil
                    )
                case .error(let error):
                    ErrorRetryView(error: error) { Task { await viewModel.load() } }
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Orders")
        .navigationBarTitleDisplayMode(.large)
        .refreshable { await viewModel.load() }
        .task { await viewModel.load() }
    }
}

struct OrderStatusChip: View {
    let label: String
    var color: Color = AppTheme.Colors.primary
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            HapticService.shared.play(.selection)
        }) {
            Text(label)
                .font(AppTheme.Typography.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs + 2)
                .background(isSelected ? AnyView(Capsule().fill(color)) : AnyView(Capsule().fill(.ultraThinMaterial)))
        }
        .buttonStyle(ScalePressEffect())
        .animation(.bouncy, value: isSelected)
    }
}

struct OrderListCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(order.orderNumber)
                        .font(AppTheme.Typography.labelMedium)
                    Text(order.createdAt.smartFormatted)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                OrderStatusBadge(status: order.status)
            }

            // Item thumbnails
            HStack(spacing: AppSpacing.sm) {
                ForEach(order.items.prefix(3)) { item in
                    AsyncCachedImage(url: item.product.primaryImage?.url)
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
                }
                if order.items.count > 3 {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 52, height: 52)
                        Text("+\(order.items.count - 3)")
                            .font(AppTheme.Typography.labelSmall)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(order.total.formatted)
                    .font(AppTheme.Typography.priceMedium)
            }

            // Delivery estimate or tracking
            if order.status.isActive {
                Label(
                    order.estimatedDelivery.map { "Est. \($0.smartFormatted)" } ?? "Tracking available",
                    systemImage: "shippingbox.fill"
                )
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}
