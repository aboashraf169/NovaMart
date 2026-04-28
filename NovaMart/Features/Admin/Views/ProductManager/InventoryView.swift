import SwiftUI

struct InventoryView: View {
    @Bindable var viewModel: AdminViewModel
    @State private var filter: InventoryFilter = .all
    @State private var editingProduct: Product? = nil

    enum InventoryFilter: String, CaseIterable {
        case all = "All"
        case low = "Low Stock"
        case out = "Out of Stock"
        case healthy = "Healthy"
    }

    var filteredProducts: [Product] {
        switch filter {
        case .all:     return viewModel.products
        case .low:     return viewModel.products.filter { $0.isLowStock && !$0.isOutOfStock }
        case .out:     return viewModel.products.filter { $0.isOutOfStock }
        case .healthy: return viewModel.products.filter { !$0.isLowStock }
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.xs) {
                filterPills
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sm)

                ForEach(filteredProducts) { product in
                    InventoryRow(product: product) {
                        editingProduct = product
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Inventory")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $editingProduct) { product in
            StockUpdateSheet(product: product) { updatedStock in
                if let idx = viewModel.products.firstIndex(where: { $0.id == product.id }) {
                    viewModel.products[idx] = product.withStock(updatedStock)
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(InventoryFilter.allCases, id: \.rawValue) { f in
                    Button {
                        withAnimation(.snappy) { filter = f }
                        HapticService.shared.play(.selection)
                    } label: {
                        Text(f.rawValue)
                            .font(AppTheme.Typography.labelSmall)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(filter == f ? AppTheme.Colors.primary : Color(UIColor.systemGray5), in: Capsule())
                            .foregroundStyle(filter == f ? .white : .primary)
                    }
                    .buttonStyle(ScalePressEffect())
                }
            }
        }
    }
}

private struct InventoryRow: View {
    let product: Product
    let onEdit: () -> Void

    var stockColor: Color {
        if product.isOutOfStock { return AppTheme.Colors.error }
        if product.isLowStock { return AppTheme.Colors.warning }
        return AppTheme.Colors.success
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncCachedImage(url: product.images.first?.url) {
                Rectangle().fill(Color(UIColor.systemGray5))
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small))

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(AppTheme.Typography.labelSmall)
                    .lineLimit(1)
                Text(product.sku.isEmpty ? product.id.uuidString.prefix(8).uppercased() : product.sku)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(stockColor)
                        .frame(width: 8, height: 8)
                    Text("\(product.stockQuantity)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(stockColor)
                }
                Text("in stock")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Button {
                onEdit()
                HapticService.shared.play(.selection)
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 15))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
            .buttonStyle(ScalePressEffect())
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

private struct StockUpdateSheet: View {
    let product: Product
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var stockText: String

    init(product: Product, onSave: @escaping (Int) -> Void) {
        self.product = product
        self.onSave = onSave
        _stockText = State(initialValue: "\(product.stockQuantity)")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.sm) {
                    Text(product.name)
                        .font(AppTheme.Typography.title3)
                        .multilineTextAlignment(.center)
                    Text("Current: \(product.stockQuantity) units")
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, AppSpacing.xl)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("New Stock Quantity")
                        .font(AppTheme.Typography.labelMedium)
                    TextField("Stock", text: $stockText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding(AppSpacing.md)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium))
                }

                GlassButton("Update Stock") {
                    if let qty = Int(stockText) {
                        onSave(qty)
                        HapticService.shared.play(.notification(.success))
                        dismiss()
                    }
                }
                .disabled(Int(stockText) == nil)
                .opacity(Int(stockText) == nil ? 0.5 : 1)

                Spacer()
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .background(AnimatedMeshBackground())
            .navigationTitle("Update Stock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private extension Product {
    func withStock(_ qty: Int) -> Product {
        Product(
            id: id, name: name, description: description,
            longDescription: longDescription, price: price,
            compareAtPrice: compareAtPrice, costPrice: costPrice,
            images: images, variants: variants, category: category,
            tags: tags, rating: rating, reviewCount: reviewCount,
            soldCount: soldCount, stockQuantity: qty,
            sku: sku, barcode: barcode, weight: weight,
            isFeatured: isFeatured, isActive: isActive,
            discountPercent: discountPercent, flashSaleEnds: flashSaleEnds,
            brand: brand, metaTitle: metaTitle, metaDescription: metaDescription,
            createdAt: createdAt, updatedAt: Date.now
        )
    }
}
