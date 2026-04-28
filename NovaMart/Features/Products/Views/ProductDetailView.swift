import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(AppState.self) private var appState
    @State private var selectedVariant: ProductVariant? = nil
    @State private var quantity = 1
    @State private var selectedImageIndex = 0
    @State private var expandedSection: DetailSection? = nil
    @State private var showReviews = false
    @Namespace private var namespace

    enum DetailSection: String, CaseIterable {
        case description = "Description"
        case specifications = "Specifications"
        case shipping = "Shipping & Returns"
    }

    var effectivePrice: Decimal {
        selectedVariant?.price ?? product.price
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Image carousel
                GeometryReader { geo in
                    ImageCarouselView(images: product.images, selectedIndex: $selectedImageIndex)
                        .frame(width: geo.size.width, height: geo.size.width * 1.1)
                }
                .aspectRatio(1.0/1.1, contentMode: .fit)
                    .overlay(alignment: .bottom) {
                        // Social proof
                        GlassEffectContainer {
                            HStack(spacing: AppSpacing.md) {
                                Label("\(Int.random(in: 12...48)) viewing", systemImage: "eye.fill")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(.primary)
                                Divider().frame(height: 12)
                                Label("\(product.soldCount.compactFormatted) sold", systemImage: "bag.fill")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.xs)
                            .glassEffect(in: .capsule)
                        }
                        .padding(.bottom, AppSpacing.md)
                    }

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Product header
                    ProductHeaderSection(product: product, effectivePrice: effectivePrice, selectedVariant: selectedVariant)

                    Divider().padding(.horizontal, AppSpacing.screenPadding)

                    // Variant selector
                    if !product.variants.isEmpty {
                        VariantSelectorView(
                            product: product,
                            selectedVariant: $selectedVariant
                        )
                        .padding(.horizontal, AppSpacing.screenPadding)

                        Divider().padding(.horizontal, AppSpacing.screenPadding)
                    }

                    // Quantity
                    QuantityStepper(quantity: $quantity, maxQuantity: selectedVariant?.stock ?? product.stockQuantity)
                        .padding(.horizontal, AppSpacing.screenPadding)

                    Divider().padding(.horizontal, AppSpacing.screenPadding)

                    // Expandable sections
                    ForEach(DetailSection.allCases, id: \.rawValue) { section in
                        ExpandableSection(
                            title: section.rawValue,
                            isExpanded: expandedSection == section
                        ) {
                            withAnimation(.bouncy) {
                                expandedSection = expandedSection == section ? nil : section
                            }
                        } content: {
                            DetailSectionContent(section: section, product: product)
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)

                        Divider().padding(.horizontal, AppSpacing.screenPadding)
                    }

                    // Reviews
                    ReviewsSection(
                        productID: product.id,
                        rating: product.rating,
                        reviewCount: product.reviewCount
                    )
                    .padding(.horizontal, AppSpacing.screenPadding)

                    // Related products
                    RelatedProductsView(productID: product.id)

                    Spacer(minLength: 100)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .bottom) {
            StickyAddToCartBar(
                product: product,
                selectedVariant: selectedVariant,
                quantity: quantity,
                effectivePrice: effectivePrice
            )
        }
        .overlay(alignment: .topLeading) {
            BackButton()
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: AppSpacing.sm) {
                WishlistButton(productID: product.id)
                ShareButton(product: product)
            }
            .padding(.trailing, AppSpacing.md)
            .padding(.top, 56)
        }
    }
}

// MARK: - Back Button
struct BackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
            HapticService.shared.play(.impact(.light))
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .padding(.leading, AppSpacing.md)
        .padding(.top, 56)
    }
}

// MARK: - Share Button
struct ShareButton: View {
    let product: Product

    var body: some View {
        ShareLink(item: URL(string: "https://novamart.app/product/\(product.id)")!) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Product Header
struct ProductHeaderSection: View {
    let product: Product
    let effectivePrice: Decimal
    let selectedVariant: ProductVariant?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(product.brand.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)

                Spacer()

                if let pct = product.savingsPercent {
                    DiscountBadge(percent: pct)
                }
            }

            Text(product.name)
                .font(AppTheme.Typography.title1)
                .foregroundStyle(.primary)

            HStack(alignment: .center, spacing: AppSpacing.md) {
                PriceView(price: effectivePrice, compareAtPrice: product.compareAtPrice, size: .large)

                Spacer()

                HStack(spacing: 6) {
                    RatingStarsView(rating: product.rating, size: 13)
                    Text("(\(product.reviewCount.compactFormatted))")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if product.isLowStock {
                Label("Only \(product.stockQuantity) left in stock", systemImage: "exclamationmark.triangle.fill")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.warning)
            }
        }
        .padding(AppSpacing.screenPadding)
    }
}

// MARK: - Quantity Stepper
struct QuantityStepper: View {
    @Binding var quantity: Int
    let maxQuantity: Int

    var body: some View {
        HStack {
            Text("Quantity")
                .font(AppTheme.Typography.labelMedium)

            Spacer()

            HStack(spacing: AppSpacing.md) {
                Button {
                    if quantity > 1 {
                        withAnimation(.bouncy) { quantity -= 1 }
                        HapticService.shared.play(.selection)
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(quantity > 1 ? .primary : .secondary)
                        .frame(width: 32, height: 32)
                        .glassEffect(.regular.interactive(), in: .circle)
                }
                .disabled(quantity <= 1)

                Text("\(quantity)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .frame(minWidth: 28)
                    .contentTransition(.numericText())

                Button {
                    if quantity < maxQuantity {
                        withAnimation(.bouncy) { quantity += 1 }
                        HapticService.shared.play(.selection)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(quantity < maxQuantity ? .primary : .secondary)
                        .frame(width: 32, height: 32)
                        .glassEffect(.regular.interactive(), in: .circle)
                }
                .disabled(quantity >= maxQuantity)
            }
        }
    }
}

// MARK: - Expandable Section
struct ExpandableSection<Content: View>: View {
    let title: String
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Button(action: onToggle) {
                HStack {
                    Text(title)
                        .font(AppTheme.Typography.labelLarge)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                        .animation(.bouncy, value: isExpanded)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

struct DetailSectionContent: View {
    let section: ProductDetailView.DetailSection
    let product: Product

    var body: some View {
        switch section {
        case .description:
            Text(product.longDescription)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        case .specifications:
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                SpecRow(label: "Brand", value: product.brand)
                SpecRow(label: "SKU", value: product.sku)
                if let weight = product.weight {
                    SpecRow(label: "Weight", value: "\(weight) kg")
                }
                SpecRow(label: "Category", value: product.category.name)
                ForEach(product.tags.prefix(4), id: \.self) { tag in
                    SpecRow(label: "Tag", value: tag)
                }
            }
        case .shipping:
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Label("Free standard shipping on orders over $75", systemImage: "shippingbox.fill")
                Label("Express delivery available at checkout", systemImage: "bolt.fill")
                Label("Free 30-day returns on most items", systemImage: "arrow.uturn.left.circle.fill")
                Label("Ships within 1-2 business days", systemImage: "clock.fill")
            }
            .font(AppTheme.Typography.bodySmall)
            .foregroundStyle(.secondary)
        }
    }
}

struct SpecRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(AppTheme.Typography.bodySmall)
                .foregroundStyle(.primary)
            Spacer()
        }
    }
}

// MARK: - Sticky Add to Cart Bar
struct StickyAddToCartBar: View {
    let product: Product
    let selectedVariant: ProductVariant?
    let quantity: Int
    let effectivePrice: Decimal
    @Environment(AppState.self) private var appState

    var isAvailable: Bool {
        let stock = selectedVariant?.stock ?? product.stockQuantity
        return stock > 0
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 1) {
                Text(isAvailable ? "In Stock" : "Out of Stock")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(isAvailable ? AppTheme.Colors.success : AppTheme.Colors.error)
                PriceView(price: effectivePrice * Decimal(quantity), compareAtPrice: nil, size: .medium)
            }

            GlassButton("Add to Cart", icon: "bag.badge.plus", isLoading: false) {
                guard isAvailable else { return }
                appState.addToCart(product, variant: selectedVariant, quantity: quantity)
            }
            .disabled(!isAvailable)
        }
        .padding(AppSpacing.md)
        .backgroundExtensionEffect()
        .glassEffect(in: .rect(cornerRadius: AppTheme.Radius.sheet))
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, AppSpacing.sm)
    }
}
