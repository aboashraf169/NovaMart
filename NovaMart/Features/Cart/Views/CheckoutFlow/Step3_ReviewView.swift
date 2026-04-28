import SwiftUI

struct Step3_ReviewView: View {
    let address: Address?
    let payment: PaymentMethod?
    let isPlacing: Bool
    let onPlaceOrder: () -> Void
    @Environment(AppState.self) private var appState

    var subtotal: Decimal { appState.cartTotal }
    var shipping: Decimal { subtotal >= 75 ? 0 : 8.99 }
    var tax: Decimal { (subtotal + shipping) * 0.08 }
    var total: Decimal { subtotal + shipping + tax }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Review Order")
                    .font(AppTheme.Typography.title2)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Items
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Items (\(appState.cartItemCount))")
                        .font(AppTheme.Typography.labelLarge)

                    ForEach(appState.cartItems) { item in
                        HStack(spacing: AppSpacing.sm) {
                            AsyncCachedImage(url: item.product.primaryImage?.url)
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.product.name)
                                    .font(AppTheme.Typography.labelSmall)
                                    .lineLimit(1)
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

                // Address summary
                if let address {
                    ReviewSection(title: "Delivering to", icon: "location.fill") {
                        Text(address.fullName).font(AppTheme.Typography.labelSmall)
                        Text(address.formatted).font(AppTheme.Typography.bodySmall).foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Payment summary
                if let payment {
                    ReviewSection(title: "Paying with", icon: payment.icon) {
                        Text(payment.displayName).font(AppTheme.Typography.labelSmall)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Price breakdown
                VStack(spacing: AppSpacing.sm) {
                    SummaryRow(label: "Subtotal", value: subtotal.formatted)
                    SummaryRow(label: shipping == 0 ? "Shipping · Free" : "Shipping", value: shipping == 0 ? "FREE" : shipping.formatted, valueColor: shipping == 0 ? AppTheme.Colors.success : .primary)
                    SummaryRow(label: "Tax", value: tax.formatted)
                    Divider()
                    HStack {
                        Text("Total")
                            .font(AppTheme.Typography.labelLarge)
                        Spacer()
                        Text(total.formatted)
                            .font(AppTheme.Typography.priceLarge)
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Place order (biometric auth prompt)
                GlassButton(
                    isPlacing ? "Placing Order..." : "Confirm & Pay \(total.formatted)",
                    icon: isPlacing ? nil : "faceid",
                    isLoading: isPlacing,
                    action: onPlaceOrder
                )
                .padding(.horizontal, AppSpacing.screenPadding)
                .buttonStyle(.glassProminent)

                Text("By placing this order you agree to our Terms of Service and authorize a charge of \(total.formatted) to your selected payment method.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.screenPadding)
            }
            .padding(.vertical, AppSpacing.md)
        }
    }
}

struct ReviewSection<Content: View>: View {
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
