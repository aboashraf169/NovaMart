import SwiftUI

struct OrderSuccessView: View {
    let order: Order
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = true
    @State private var appeared = false

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            ConfettiView(isActive: showConfetti)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // Success icon
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.success.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(AppTheme.Colors.success.opacity(0.3))
                        .frame(width: 90, height: 90)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.success)
                }
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)

                // Text
                VStack(spacing: AppSpacing.sm) {
                    Text("Order Placed!")
                        .font(.system(size: 34, weight: .black))
                        .opacity(appeared ? 1 : 0)

                    Text("Your order **\(order.orderNumber)** has been confirmed and is being processed.")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                }

                // Order summary card
                GlassEffectContainer {
                    VStack(spacing: AppSpacing.md) {
                        OrderSuccessRow(label: "Order Number", value: order.orderNumber)
                        Divider()
                        OrderSuccessRow(label: "Total", value: order.total.formatted)
                        Divider()
                        OrderSuccessRow(
                            label: "Estimated Delivery",
                            value: order.estimatedDelivery.map { $0.mediumFormatted } ?? "3-5 business days"
                        )
                        Divider()
                        OrderSuccessRow(label: "Payment", value: order.paymentMethod.displayName)
                    }
                    .padding(AppSpacing.cardPadding)
                    .glassEffect(in: .rect(cornerRadius: AppTheme.Radius.card))
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Spacer()

                // Actions
                VStack(spacing: AppSpacing.md) {
                    NavigationLink(destination: OrderDetailView(order: order)) {
                        GlassButton("Track Order", icon: "location.fill") {}
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .simultaneousGesture(TapGesture().onEnded { dismiss() })

                    Button("Continue Shopping") {
                        appState.selectedTab = .home
                        dismiss()
                    }
                    .font(AppTheme.Typography.labelMedium)
                    .foregroundStyle(.secondary)
                }
                .opacity(appeared ? 1 : 0)
            }
            .padding(.vertical, AppSpacing.xl)
        }
        .onAppear {
            withAnimation(.bouncy.delay(0.2)) {
                appeared = true
            }
            Task {
                try? await Task.sleep(for: .seconds(4))
                showConfetti = false
            }
        }
    }
}

struct OrderSuccessRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.bodySmall)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(AppTheme.Typography.labelSmall)
        }
    }
}
