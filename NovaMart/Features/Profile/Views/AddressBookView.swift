import SwiftUI

struct AddressBookView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddAddress = false
    @State private var editingAddress: Address? = nil

    var addresses: [Address] {
        appState.currentUser?.addresses ?? [Address.sample]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.sm) {
                ForEach(addresses) { address in
                    AddressCard(address: address) {
                        editingAddress = address
                    } onDelete: {
                        deleteAddress(address)
                    } onSetDefault: {
                        setDefault(address)
                    }
                }

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
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Address Book")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddAddress) {
            AddEditAddressView(address: nil) { newAddress in
                appState.currentUser?.addresses.append(newAddress)
            }
            .presentationDetents([.large])
        }
        .sheet(item: $editingAddress) { address in
            AddEditAddressView(address: address) { updated in
                if let idx = appState.currentUser?.addresses.firstIndex(where: { $0.id == updated.id }) {
                    appState.currentUser?.addresses[idx] = updated
                }
            }
            .presentationDetents([.large])
        }
    }

    private func deleteAddress(_ address: Address) {
        withAnimation(.smooth) {
            appState.currentUser?.addresses.removeAll { $0.id == address.id }
        }
        HapticService.shared.play(.impact(.medium))
    }

    private func setDefault(_ address: Address) {
        appState.currentUser?.defaultAddressID = address.id
        HapticService.shared.play(.selection)
    }
}

struct AddressCard: View {
    let address: Address
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: address.label == "Home" ? "house.fill" : "building.2.fill")
                        .foregroundStyle(AppTheme.Colors.primary)
                    Text(address.label)
                        .font(AppTheme.Typography.labelMedium)
                }
                Spacer()
                if address.isDefault {
                    GlassBadge(text: "Default", color: AppTheme.Colors.secondary, size: .small)
                }
            }

            Text(address.fullName)
                .font(AppTheme.Typography.bodySmall)

            Text(address.formatted)
                .font(AppTheme.Typography.bodySmall)
                .foregroundStyle(.secondary)

            if let phone = address.phone {
                Text(phone)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: AppSpacing.md) {
                Button("Edit", action: onEdit)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.primary)

                Button("Delete", action: onDelete)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.error)

                Spacer()

                if !address.isDefault {
                    Button("Set as Default", action: onSetDefault)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

struct AddEditAddressView: View {
    let address: Address?
    let onSave: (Address) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var label = "Home"
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var line1 = ""
    @State private var line2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = "United States"
    @State private var phone = ""
    @State private var isDefault = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    // Label
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(["Home", "Work", "Other"], id: \.self) { lbl in
                            Button(lbl) { label = lbl }
                                .font(AppTheme.Typography.labelSmall)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(label == lbl ? AnyView(Capsule().fill(AppTheme.Colors.primaryGradient)) : AnyView(Capsule().fill(.ultraThinMaterial)))
                                .foregroundStyle(label == lbl ? .white : .primary)
                                .buttonStyle(ScalePressEffect())
                        }
                        Spacer()
                    }

                    HStack(spacing: AppSpacing.sm) {
                        AuthField(title: "First Name", text: $firstName, icon: "person", type: .givenName)
                        AuthField(title: "Last Name", text: $lastName, icon: "person", type: .familyName)
                    }

                    AuthField(title: "Address Line 1", text: $line1, icon: "location.fill", type: .streetAddressLine1)
                    AuthField(title: "Address Line 2 (Optional)", text: $line2, icon: "location", type: .streetAddressLine2)

                    HStack(spacing: AppSpacing.sm) {
                        AuthField(title: "City", text: $city, icon: "building.fill", type: .addressCity)
                        AuthField(title: "State", text: $state, icon: "map.fill", type: .addressState)
                    }

                    HStack(spacing: AppSpacing.sm) {
                        AuthField(title: "Postal Code", text: $postalCode, icon: "envelope.fill", type: .postalCode)
                        AuthField(title: "Phone", text: $phone, icon: "phone.fill", type: .telephoneNumber)
                    }

                    FilterToggle(label: "Set as default address", icon: "star.fill", isOn: $isDefault)

                    GlassButton(address == nil ? "Add Address" : "Save Changes", icon: "checkmark") {
                        let saved = Address(
                            id: address?.id ?? UUID(),
                            label: label,
                            firstName: firstName,
                            lastName: lastName,
                            line1: line1,
                            line2: line2.isEmpty ? nil : line2,
                            city: city,
                            state: state,
                            postalCode: postalCode,
                            country: country,
                            phone: phone.isEmpty ? nil : phone,
                            isDefault: isDefault
                        )
                        onSave(saved)
                        dismiss()
                        HapticService.shared.play(.notification(.success))
                    }
                }
                .padding(AppSpacing.screenPadding)
            }
            .background(AnimatedMeshBackground())
            .navigationTitle(address == nil ? "New Address" : "Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let a = address {
                    label = a.label; firstName = a.firstName; lastName = a.lastName
                    line1 = a.line1; line2 = a.line2 ?? ""; city = a.city
                    state = a.state; postalCode = a.postalCode; phone = a.phone ?? ""
                    isDefault = a.isDefault
                }
            }
        }
    }
}
