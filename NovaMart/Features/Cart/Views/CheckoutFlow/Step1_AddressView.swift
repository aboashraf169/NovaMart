import SwiftUI

struct Step1_AddressView: View {
    @Binding var selectedAddress: Address?
    @Environment(AppState.self) private var appState
    @State private var showAddAddress = false

    var addresses: [Address] {
        appState.currentUser?.addresses ?? [Address.sample]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Delivery Address")
                    .font(AppTheme.Typography.title2)
                    .padding(.horizontal, AppSpacing.screenPadding)

                VStack(spacing: AppSpacing.sm) {
                    ForEach(addresses) { address in
                        AddressSelectionCard(
                            address: address,
                            isSelected: selectedAddress?.id == address.id
                        ) {
                            withAnimation(.bouncy) { selectedAddress = address }
                            HapticService.shared.play(.selection)
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }

                // Add new address
                Button {
                    showAddAddress = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.Colors.primary)
                        Text("Add New Address")
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
            }
            .padding(.vertical, AppSpacing.md)
        }
        .sheet(isPresented: $showAddAddress) {
            AddEditAddressView(address: nil) { _ in }
                .presentationDetents([.large])
        }
    }
}

struct AddressSelectionCard: View {
    let address: Address
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? AppTheme.Colors.primary : Color(UIColor.systemGray4), lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(AppTheme.Colors.primaryGradient)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 2)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text(address.label)
                            .font(AppTheme.Typography.labelMedium)
                        if address.isDefault {
                            GlassBadge(text: "Default", color: AppTheme.Colors.secondary, size: .small)
                        }
                    }
                    Text(address.fullName)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundStyle(.secondary)
                    Text(address.formatted)
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundStyle(.secondary)
                    if let phone = address.phone {
                        Text(phone)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
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
