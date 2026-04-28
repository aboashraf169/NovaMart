import SwiftUI

struct FilterSheetView: View {
    @Binding var filter: SearchFilter
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var tempFilter: SearchFilter = .empty
    @State private var priceRange: ClosedRange<Double> = 0...1000
    @State private var selectedCategory: Category? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    // Sort
                    FilterSection(title: "Sort By") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                            ForEach(SortOrder.allCases, id: \.rawValue) { sort in
                                SortChip(
                                    sort: sort,
                                    isSelected: tempFilter.sortOrder == sort
                                ) {
                                    HapticService.shared.play(.selection)
                                    tempFilter.sortOrder = sort
                                }
                            }
                        }
                    }

                    // Category
                    FilterSection(title: "Category") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.sm) {
                                CategoryFilterChip(
                                    name: "All",
                                    icon: "square.grid.2x2.fill",
                                    isSelected: tempFilter.categoryID == nil
                                ) {
                                    tempFilter.categoryID = nil
                                }

                                ForEach(Category.allCategories) { category in
                                    CategoryFilterChip(
                                        name: category.name,
                                        icon: category.iconName,
                                        isSelected: tempFilter.categoryID == category.id
                                    ) {
                                        HapticService.shared.play(.selection)
                                        tempFilter.categoryID = category.id
                                    }
                                }
                            }
                        }
                    }

                    // Price range
                    FilterSection(title: "Price Range") {
                        PriceRangeSection(tempFilter: $tempFilter)
                    }

                    // Rating
                    FilterSection(title: "Minimum Rating") {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach([4.5, 4.0, 3.5, 3.0], id: \.self) { rating in
                                Button {
                                    HapticService.shared.play(.selection)
                                    tempFilter.minRating = tempFilter.minRating == rating ? nil : rating
                                } label: {
                                    HStack(spacing: 3) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color(hex: "#FFD700"))
                                        Text("\(String(format: "%.1f", rating))+")
                                            .font(AppTheme.Typography.labelSmall)
                                    }
                                    .padding(.horizontal, AppSpacing.sm)
                                    .padding(.vertical, AppSpacing.xs + 2)
                                    .background(
                                        tempFilter.minRating == rating
                                        ? AnyView(Capsule().fill(AppTheme.Colors.primaryGradient))
                                        : AnyView(Capsule().fill(.ultraThinMaterial))
                                    )
                                    .foregroundStyle(tempFilter.minRating == rating ? .white : .primary)
                                }
                                .buttonStyle(ScalePressEffect())
                            }
                        }
                    }

                    // Toggles
                    FilterSection(title: "Availability") {
                        VStack(spacing: AppSpacing.sm) {
                            FilterToggle(label: "In Stock Only", icon: "shippingbox.fill", isOn: $tempFilter.inStockOnly)
                            FilterToggle(label: "On Sale Only", icon: "tag.fill", isOn: $tempFilter.onSaleOnly)
                        }
                    }
                }
                .padding(AppSpacing.screenPadding)
            }
            .background(AnimatedMeshBackground())
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        tempFilter = .empty
                        HapticService.shared.play(.impact(.light))
                    }
                    .foregroundStyle(AppTheme.Colors.error)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        filter = tempFilter
                        onApply()
                        dismiss()
                        HapticService.shared.play(.notification(.success))
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.primary)
                }
            }
        }
        .onAppear { tempFilter = filter }
    }
}

private struct PriceRangeSection: View {
    @Binding var tempFilter: SearchFilter

    private func minInt() -> Int { NSDecimalNumber(decimal: tempFilter.minPrice ?? 0).intValue }
    private func maxInt() -> Int { NSDecimalNumber(decimal: tempFilter.maxPrice ?? 1000).intValue }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text("$\(minInt())")
                    .font(AppTheme.Typography.labelSmall)
                Spacer()
                Text("$\(maxInt())")
                    .font(AppTheme.Typography.labelSmall)
            }
            .foregroundStyle(.secondary)

            HStack(spacing: AppSpacing.sm) {
                ForEach([(0, 50), (50, 150), (150, 300), (300, 1000)], id: \.0) { min, max in
                    let label = max == 1000 ? "$\(min)+" : "$\(min)-$\(max)"
                    let isSelected = minInt() == min && (max == 1000 ? tempFilter.maxPrice == nil : maxInt() == max)
                    PriceRangeChip(label: label, isSelected: isSelected) {
                        Task { @MainActor in HapticService.shared.play(.selection) }
                        tempFilter.minPrice = Decimal(min)
                        tempFilter.maxPrice = max == 1000 ? nil : Decimal(max)
                    }
                }
            }
        }
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTheme.Typography.labelLarge)
            content()
        }
    }
}

struct SortChip: View {
    let sort: SortOrder
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: sort.icon)
                    .font(.system(size: 11))
                Text(sort.displayName)
                    .font(AppTheme.Typography.caption)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs + 2)
            .frame(maxWidth: .infinity)
            .background(isSelected ? AnyView(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppTheme.Colors.primaryGradient)) : AnyView(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.ultraThinMaterial)))
        }
        .buttonStyle(ScalePressEffect())
    }
}

struct CategoryFilterChip: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon).font(.system(size: 12))
                Text(name).font(AppTheme.Typography.caption)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs + 2)
            .background(isSelected ? AnyView(Capsule().fill(AppTheme.Colors.primaryGradient)) : AnyView(Capsule().fill(.ultraThinMaterial)))
        }
        .buttonStyle(ScalePressEffect())
    }
}

struct PriceRangeChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs + 2)
                .background(isSelected ? AnyView(Capsule().fill(AppTheme.Colors.primaryGradient)) : AnyView(Capsule().fill(.ultraThinMaterial)))
        }
        .buttonStyle(ScalePressEffect())
    }
}

struct FilterToggle: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.Colors.primary)
                .frame(width: 24)
            Text(label)
                .font(AppTheme.Typography.bodySmall)
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(AppTheme.Colors.primary)
                .labelsHidden()
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}
