import SwiftUI

struct PaymentMethodsView: View {
    @Environment(AppState.self) private var appState

    var methods: [PaymentMethod] {
        appState.currentUser?.paymentMethods ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.sm) {
                ForEach(methods) { method in
                    PaymentMethodRow(method: method) {
                        removeMethod(method)
                    }
                }

                Button {
                } label: {
                    HStack {
                        Image(systemName: "creditcard.fill").foregroundStyle(AppTheme.Colors.primary)
                        Text("Add Card").font(AppTheme.Typography.labelMedium).foregroundStyle(AppTheme.Colors.primary)
                        Spacer()
                    }
                    .padding(AppSpacing.cardPadding)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous).strokeBorder(AppTheme.Colors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                }
                .buttonStyle(ScalePressEffect())

                Label("Your payment information is encrypted and secured", systemImage: "lock.shield.fill")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.large)
    }

    private func removeMethod(_ method: PaymentMethod) {
        appState.currentUser?.paymentMethods.removeAll { $0.id == method.id }
        HapticService.shared.play(.impact(.medium))
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: method.icon)
                .font(.system(size: 24))
                .foregroundStyle(method.brand?.color ?? AppTheme.Colors.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(method.displayName)
                    .font(AppTheme.Typography.labelMedium)
                if let month = method.expiryMonth, let year = method.expiryYear {
                    Text("Expires \(month)/\(year % 100)")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(method.isExpired ? AppTheme.Colors.error : .secondary)
                }
            }

            Spacer()

            if method.isDefault {
                GlassBadge(text: "Default", color: AppTheme.Colors.secondary, size: .small)
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Remove", systemImage: "trash.fill")
            }
        }
    }
}
