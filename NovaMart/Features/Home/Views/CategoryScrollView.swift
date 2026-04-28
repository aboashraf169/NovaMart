import SwiftUI

struct CategoryScrollView: View {
    let categories: [Category]
    @Environment(AppState.self) private var appState
    @State private var selectedCategory: Category? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Categories", action: nil)
                .padding(.horizontal, AppSpacing.screenPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                        Button {
                            selectedCategory = category
                        } label: {
                            CategoryChip(category: category)
                                .staggeredAppear(index: index, delay: 0.04)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, 2)
            }
        }
        .navigationDestination(item: $selectedCategory) { category in
            ProductGridView(
                filter: SearchFilter(
                    query: "", categoryID: category.id,
                    minPrice: nil, maxPrice: nil, minRating: nil,
                    brands: [], tags: [], inStockOnly: false,
                    onSaleOnly: false, sortOrder: .featured
                ),
                title: category.name
            )
        }
    }
}

struct CategoryChip: View {
    let category: Category
    @State private var pressed = false

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ZStack {
                Circle()
                    .fill(category.swiftUIColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: category.iconName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(category.swiftUIColor)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(category.name)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(.primary)
                Text("\(category.productCount)")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.leading, 4)
        .padding(.trailing, AppSpacing.md)
        .padding(.vertical, AppSpacing.xs)
        .background {
            Capsule()
                .fill(.thinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(category.swiftUIColor.opacity(0.2), lineWidth: 1)
                )
        }
        .scaleEffect(pressed ? 0.95 : 1.0)
        .animation(.bouncy(duration: 0.2), value: pressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            pressed = pressing
        }, perform: {})
        .accessibilityLabel("\(category.name), \(category.productCount) products")
    }
}

struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?
    var actionTitle: String = "See All"

    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.title3)

            Spacer()

            if let action {
                Button(actionTitle, action: action)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.primary)
            }
        }
    }
}
