import SwiftUI

struct Step2_PaymentView: View {
    @Binding var selectedPayment: PaymentMethod?
    @Environment(AppState.self) private var appState

    var paymentMethods: [PaymentMethod] {
        appState.currentUser?.paymentMethods ?? [
            PaymentMethod(id: UUID(), type: .applePay, last4: nil, brand: nil, expiryMonth: nil, expiryYear: nil, isDefault: true),
            PaymentMethod(id: UUID(), type: .card, last4: "4242", brand: .visa, expiryMonth: 12, expiryYear: 2027, isDefault: false)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Payment Method")
                    .font(AppTheme.Typography.title2)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Apple Pay (featured)
                if let applePay = paymentMethods.first(where: { $0.type == .applePay }) {
                    Button {
                        withAnimation(.bouncy) { selectedPayment = applePay }
                        HapticService.shared.play(.selection)
                    } label: {
                        HStack {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 22, weight: .semibold))
                            Text("Pay")
                                .font(.system(size: 22, weight: .semibold))
                            Spacer()
                            Image(systemName: selectedPayment?.type == .applePay ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedPayment?.type == .applePay ? AppTheme.Colors.primary : .secondary)
                        }
                        .padding(AppSpacing.cardPadding)
                        .glassCard(tint: selectedPayment?.type == .applePay ? AppTheme.Colors.primary : nil)
                        .overlay {
                            if selectedPayment?.type == .applePay {
                                RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                                    .strokeBorder(AppTheme.Colors.primary.opacity(0.5), lineWidth: 1.5)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Other methods
                let otherMethods = paymentMethods.filter { $0.type != .applePay }
                if !otherMethods.isEmpty {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(otherMethods) { method in
                            PaymentMethodCard(
                                method: method,
                                isSelected: selectedPayment?.id == method.id
                            ) {
                                withAnimation(.bouncy) { selectedPayment = method }
                                HapticService.shared.play(.selection)
                            }
                            .padding(.horizontal, AppSpacing.screenPadding)
                        }
                    }
                }

                // Add card
                Button {
                } label: {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundStyle(AppTheme.Colors.primary)
                        Text("Add Payment Method")
                            .font(AppTheme.Typography.labelMedium)
                            .foregroundStyle(AppTheme.Colors.primary)
                        Spacer()
                    }
                    .padding(AppSpacing.cardPadding)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                            .strokeBorder(AppTheme.Colors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )
                }
                .buttonStyle(ScalePressEffect())
                .padding(.horizontal, AppSpacing.screenPadding)

                // Security note
                Label("All transactions are secured with 256-bit SSL encryption", systemImage: "lock.shield.fill")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, AppSpacing.screenPadding)
            }
            .padding(.vertical, AppSpacing.md)
        }
    }
}

struct PaymentMethodCard: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: method.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(method.brand?.color ?? AppTheme.Colors.primary)
                    .frame(width: 36)

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

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AppTheme.Colors.primary : .secondary)
            }
            .padding(AppSpacing.cardPadding)
            .glassCard(tint: isSelected ? AppTheme.Colors.primary : nil)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                        .strokeBorder(AppTheme.Colors.primary.opacity(0.5), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.bouncy, value: isSelected)
    }
}
