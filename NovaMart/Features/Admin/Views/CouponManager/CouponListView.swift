import SwiftUI

struct CouponListView: View {
    @Bindable var viewModel: AdminViewModel
    @State private var showAddCoupon = false
    @State private var editingCoupon: Coupon? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.coupons) { coupon in
                    CouponRow(coupon: coupon) {
                        editingCoupon = coupon
                    } onDelete: {
                        withAnimation(.smooth) { viewModel.deleteCoupon(coupon) }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Coupons")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddCoupon = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showAddCoupon) {
            AddEditCouponView(coupon: nil) { newCoupon in
                viewModel.coupons.append(newCoupon)
            }
            .presentationDetents([.large])
        }
        .sheet(item: $editingCoupon) { coupon in
            AddEditCouponView(coupon: coupon) { updated in
                if let idx = viewModel.coupons.firstIndex(where: { $0.id == updated.id }) {
                    viewModel.coupons[idx] = updated
                }
            }
            .presentationDetents([.large])
        }
    }
}

struct CouponRow: View {
    let coupon: Coupon
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous)
                    .fill(coupon.isValid ? AnyShapeStyle(AppTheme.Colors.primaryGradient) : AnyShapeStyle(Color(UIColor.systemGray5)))
                    .frame(width: 44, height: 44)
                Image(systemName: coupon.type.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(coupon.isValid ? .white : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(coupon.code)
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                    if !coupon.isActive {
                        GlassBadge(text: "Inactive", color: .secondary, size: .small)
                    } else if coupon.isExpired {
                        GlassBadge(text: "Expired", color: AppTheme.Colors.error, size: .small)
                    }
                }
                Text(coupon.description)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: AppSpacing.sm) {
                    Text("Used: \(coupon.usedCount)\(coupon.usageLimit.map { "/\($0)" } ?? "")")
                    if let exp = coupon.expiresAt {
                        Text("· Expires \(exp.shortFormatted)")
                    }
                }
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                if coupon.type == .percentage {
                    Text("\(Int(NSDecimalNumber(decimal: coupon.value).doubleValue))% Off")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.primary)
                } else if coupon.type == .fixed {
                    Text(coupon.value.formatted)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.primary)
                } else {
                    Text("Free Ship")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.secondary)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash.fill")
            }
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppTheme.Colors.primary)
        }
    }
}

struct AddEditCouponView: View {
    let coupon: Coupon?
    let onSave: (Coupon) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var type: CouponType = .percentage
    @State private var value: String = ""
    @State private var minOrder: String = ""
    @State private var usageLimit: String = ""
    @State private var perCustomerLimit: String = ""
    @State private var expiresAt = Date.now.addingTimeInterval(86400 * 30)
    @State private var hasExpiry = true
    @State private var isActive = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Coupon Details") {
                    HStack {
                        TextField("Code (e.g. SAVE20)", text: $code)
                            .textInputAutocapitalization(.characters)
                        Button("Generate") {
                            code = String((0..<8).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
                        }
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundStyle(AppTheme.Colors.primary)
                    }

                    Picker("Type", selection: $type) {
                        ForEach(CouponType.allCases, id: \.rawValue) { t in
                            Text(t.displayName).tag(t)
                        }
                    }

                    if type != .freeShipping {
                        HStack {
                            Text(type == .percentage ? "%" : "$")
                            TextField("Value", text: $value).keyboardType(.decimalPad)
                        }
                    }
                }
                .listRowBackground(Color.clear)

                Section("Restrictions") {
                    HStack {
                        Text("Min Order $")
                        TextField("0.00", text: $minOrder).keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Total Usage Limit")
                        Spacer()
                        TextField("Unlimited", text: $usageLimit).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Per Customer")
                        Spacer()
                        TextField("Unlimited", text: $perCustomerLimit).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                    }
                }
                .listRowBackground(Color.clear)

                Section("Expiry") {
                    Toggle("Has expiry date", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("Expires At", selection: $expiresAt, in: Date.now..., displayedComponents: [.date])
                    }
                    Toggle("Active", isOn: $isActive)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(AnimatedMeshBackground())
            .navigationTitle(coupon == nil ? "New Coupon" : "Edit Coupon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .disabled(code.isEmpty)
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        guard let c = coupon else { return }
        code = c.code; type = c.type
        value = "\(NSDecimalNumber(decimal: c.value).doubleValue)"
        minOrder = c.minimumOrderAmount.map { "\(NSDecimalNumber(decimal: $0).doubleValue)" } ?? ""
        usageLimit = c.usageLimit.map { "\($0)" } ?? ""
        perCustomerLimit = c.usageLimitPerCustomer.map { "\($0)" } ?? ""
        hasExpiry = c.expiresAt != nil
        expiresAt = c.expiresAt ?? Date.now.addingTimeInterval(86400 * 30)
        isActive = c.isActive
    }

    private func save() {
        let saved = Coupon(
            id: coupon?.id ?? UUID(),
            code: code.uppercased(),
            type: type,
            value: Decimal(string: value) ?? 0,
            minimumOrderAmount: Decimal(string: minOrder),
            usageLimit: Int(usageLimit),
            usageLimitPerCustomer: Int(perCustomerLimit),
            usedCount: coupon?.usedCount ?? 0,
            expiresAt: hasExpiry ? expiresAt : nil,
            isActive: isActive,
            description: "\(type.displayName) coupon",
            createdAt: coupon?.createdAt ?? Date.now
        )
        onSave(saved)
        Task { @MainActor in HapticService.shared.play(.notification(.success)) }
        dismiss()
    }
}
