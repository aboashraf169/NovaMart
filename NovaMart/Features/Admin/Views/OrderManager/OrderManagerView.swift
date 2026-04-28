import SwiftUI

struct OrderManagerView: View {
    @Bindable var viewModel: AdminViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        OrderStatusChip(label: "All", isSelected: viewModel.orderStatusFilter == nil) {
                            viewModel.orderStatusFilter = nil
                        }
                        ForEach(OrderStatus.allCases.prefix(6), id: \.rawValue) { status in
                            OrderStatusChip(label: status.displayName, color: status.color, isSelected: viewModel.orderStatusFilter == status) {
                                viewModel.orderStatusFilter = status
                                HapticService.shared.play(.selection)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                ForEach(viewModel.filteredOrders) { order in
                    NavigationLink(destination: OrderDetailAdminView(order: order, viewModel: viewModel)) {
                        AdminOrderRow(order: order)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Orders")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AdminOrderRow: View {
    let order: Order

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(order.orderNumber)
                    .font(AppTheme.Typography.labelMedium)
                Text(order.customer.name)
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundStyle(.secondary)
                Text(order.createdAt.smartFormatted)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text(order.total.formatted)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                OrderStatusBadge(status: order.status)
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

struct OrderDetailAdminView: View {
    let order: Order
    @Bindable var viewModel: AdminViewModel
    @State private var selectedStatus: OrderStatus = .pending
    @State private var trackingInput = ""
    @State private var showStatusPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Status update
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Order Status")
                        .font(AppTheme.Typography.labelLarge)

                    HStack {
                        OrderStatusBadge(status: order.status)
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                        Picker("New Status", selection: $selectedStatus) {
                            ForEach(OrderStatus.allCases, id: \.rawValue) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    GlassButton("Update Status") {
                        viewModel.updateOrderStatus(order, status: selectedStatus)
                        HapticService.shared.play(.notification(.success))
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Tracking
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Tracking Number")
                        .font(AppTheme.Typography.labelLarge)
                    HStack {
                        TextField("Enter tracking number", text: $trackingInput)
                            .font(AppTheme.Typography.bodyMedium)
                        Button("Save") {
                            HapticService.shared.play(.impact(.medium))
                        }
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Customer
                OrderInfoSection(title: order.customer.name, icon: "person.fill") {
                    Text(order.customer.email).font(AppTheme.Typography.bodySmall).foregroundStyle(.secondary)
                    if let phone = order.customer.phone { Text(phone).font(AppTheme.Typography.caption).foregroundStyle(.secondary) }
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                // Items
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Items (\(order.itemCount))")
                        .font(AppTheme.Typography.labelLarge)
                    ForEach(order.items) { item in
                        HStack {
                            AsyncCachedImage(url: item.product.primaryImage?.url)
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.product.name).font(AppTheme.Typography.labelSmall).lineLimit(1)
                                Text("Qty: \(item.quantity)").font(AppTheme.Typography.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(item.lineTotal.formatted).font(AppTheme.Typography.priceSmall)
                        }
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle(order.orderNumber)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { selectedStatus = order.status; trackingInput = order.trackingNumber ?? "" }
    }
}
