import SwiftUI

struct PriceSummaryView: View {
    @Bindable var viewModel: CartViewModel
    @Environment(AppState.self) private var appState

    var subtotal: Decimal { appState.cartTotal }
    var discount: Decimal { viewModel.discount(on: subtotal) }
    var shipping: Decimal { viewModel.shippingCost(subtotal: subtotal) }
    var tax: Decimal { (subtotal - discount + shipping) * 0.08 }
    var total: Decimal { subtotal - discount + shipping + tax }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Order Summary")
                .font(AppTheme.Typography.labelLarge)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppSpacing.sm) {
                SummaryRow(label: "Subtotal", value: subtotal.formatted)

                if discount > 0 {
                    SummaryRow(
                        label: viewModel.appliedCoupon.map { "Coupon (\($0.code))" } ?? "Discount",
                        value: "-\(discount.formatted)",
                        valueColor: AppTheme.Colors.success
                    )
                }

                SummaryRow(
                    label: shipping == 0 ? "Shipping · Free" : "Shipping",
                    value: shipping == 0 ? "FREE" : shipping.formatted,
                    valueColor: shipping == 0 ? AppTheme.Colors.success : .primary
                )

                SummaryRow(label: "Tax (8%)", value: tax.formatted)

                Divider()

                HStack {
                    Text("Total")
                        .font(AppTheme.Typography.labelLarge)
                    Spacer()
                    Text(total.formatted)
                        .font(AppTheme.Typography.priceLarge)
                        .foregroundStyle(AppTheme.Colors.primary)
                        .contentTransition(.numericText())
                        .animation(.bouncy, value: total)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.bodySmall)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(valueColor)
        }
    }
}

struct CartUpsellSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("You might also like")
                .font(AppTheme.Typography.title3)
                .padding(.horizontal, AppSpacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(Array(Product.samples.shuffled().prefix(4))) { product in
                        RelatedProductCard(product: product)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }
}
