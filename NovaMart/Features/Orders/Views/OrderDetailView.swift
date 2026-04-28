import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @State private var showCancelConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Status header
                VStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(order.status.color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: order.status.icon)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(order.status.color)
                    }
                    .pulseEffect(color: order.status.color, radius: 20)

                    Text(order.status.displayName)
                        .font(AppTheme.Typography.title2)
                    Text(order.orderNumber)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.xl)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Tracking
                if order.status.isActive {
                    NavigationLink(destination: OrderTrackingView(order: order)) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(AppTheme.Colors.secondary)
                            Text("Track Your Order")
                                .font(AppTheme.Typography.labelMedium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(AppSpacing.cardPadding)
                        .glassCard(tint: AppTheme.Colors.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Items
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Items")
                        .font(AppTheme.Typography.labelLarge)

                    ForEach(order.items) { item in
                        HStack(spacing: AppSpacing.md) {
                            AsyncCachedImage(url: item.product.primaryImage?.url)
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.product.name)
                                    .font(AppTheme.Typography.labelSmall)
                                if let variant = item.variant {
                                    Text(variant.name)
                                        .font(AppTheme.Typography.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("Qty: \(item.quantity)")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(item.lineTotal.formatted)
                                .font(AppTheme.Typography.priceSmall)
                        }
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Shipping info
                OrderInfoSection(title: "Shipping Address", icon: "location.fill") {
                    Text(order.shippingAddress.fullName).font(AppTheme.Typography.bodySmall)
                    Text(order.shippingAddress.formatted).font(AppTheme.Typography.bodySmall).foregroundStyle(.secondary)
                    if let tracking = order.trackingNumber {
                        HStack {
                            Text("Tracking: \(tracking)")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                            Button("Copy") {
                                UIPasteboard.general.string = tracking
                                HapticService.shared.play(.impact(.light))
                            }
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.primary)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                // Payment
                OrderInfoSection(title: "Payment", icon: order.paymentMethod.icon) {
                    Text(order.paymentMethod.displayName).font(AppTheme.Typography.bodySmall)
                    HStack {
                        Text("Status:")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                        Text(order.paymentStatus.displayName)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(order.paymentStatus.color)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                // Price breakdown
                VStack(spacing: AppSpacing.sm) {
                    SummaryRow(label: "Subtotal", value: order.subtotal.formatted)
                    if order.discountAmount > 0 {
                        SummaryRow(label: "Discount", value: "-\(order.discountAmount.formatted)", valueColor: AppTheme.Colors.success)
                    }
                    SummaryRow(label: "Shipping", value: order.shippingCost == 0 ? "FREE" : order.shippingCost.formatted, valueColor: order.shippingCost == 0 ? AppTheme.Colors.success : .primary)
                    SummaryRow(label: "Tax", value: order.taxAmount.formatted)
                    Divider()
                    HStack {
                        Text("Total").font(AppTheme.Typography.labelLarge)
                        Spacer()
                        Text(order.total.formatted).font(AppTheme.Typography.priceLarge).foregroundStyle(AppTheme.Colors.primary)
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Cancel button (if applicable)
                if !order.status.isTerminal && order.status != .shipped && order.status != .outForDelivery {
                    GlassButton("Cancel Order", style: .destructive) {
                        showCancelConfirm = true
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle(order.orderNumber)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Cancel Order?", isPresented: $showCancelConfirm, titleVisibility: .visible) {
            Button("Cancel Order", role: .destructive) {}
            Button("Never Mind", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this order? This cannot be undone.")
        }
    }
}

struct OrderInfoSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Label(title, systemImage: icon)
                .font(AppTheme.Typography.labelLarge)
            content()
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}
