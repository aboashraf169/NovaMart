import SwiftUI

struct ProductManagerView: View {
    @Bindable var viewModel: AdminViewModel
    @State private var showAddProduct = false
    @State private var editingProduct: Product? = nil
    @State private var sortOrder: SortOrder = .newest
    @State private var showInventory = false
    @State private var showBulkActions = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Search
                GlassSearchBar(text: $viewModel.productSearch)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Stats row
                HStack(spacing: AppSpacing.sm) {
                    StatPill(label: "Total", value: "\(viewModel.products.count)", color: AppTheme.Colors.primary)
                    StatPill(label: "Active", value: "\(viewModel.products.filter { $0.isActive }.count)", color: AppTheme.Colors.success)
                    StatPill(label: "Low Stock", value: "\(viewModel.products.filter { $0.isLowStock }.count)", color: AppTheme.Colors.warning)
                    StatPill(label: "OOS", value: "\(viewModel.products.filter { $0.isOutOfStock }.count)", color: AppTheme.Colors.error)
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                // Product list
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.filteredProducts) { product in
                        AdminProductRow(product: product, viewModel: viewModel) {
                            editingProduct = product
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Products")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showAddProduct = true } label: {
                        Label("Add Product", systemImage: "plus.circle")
                    }
                    Button { showInventory = true } label: {
                        Label("Inventory", systemImage: "shippingbox")
                    }
                    Button { showBulkActions = true } label: {
                        Label("Bulk Actions", systemImage: "checklist")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
            }
        }
        .navigationDestination(isPresented: $showInventory) {
            InventoryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showBulkActions) {
            BulkActionsView(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showAddProduct) {
            AddEditProductView(product: nil) { newProduct in
                viewModel.products.append(newProduct)
            }
            .presentationDetents([.large])
        }
        .sheet(item: $editingProduct) { product in
            AddEditProductView(product: product) { updated in
                if let idx = viewModel.products.firstIndex(where: { $0.id == updated.id }) {
                    viewModel.products[idx] = updated
                }
            }
            .presentationDetents([.large])
        }
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
    }
}

struct AdminProductRow: View {
    let product: Product
    @Bindable var viewModel: AdminViewModel
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncCachedImage(url: product.primaryImage?.url)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    if product.isOutOfStock {
                        Circle().fill(AppTheme.Colors.error).frame(width: 12, height: 12)
                    } else if product.isLowStock {
                        Circle().fill(AppTheme.Colors.warning).frame(width: 12, height: 12)
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(AppTheme.Typography.labelSmall)
                    .lineLimit(1)
                Text("SKU: \(product.sku)")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                HStack(spacing: AppSpacing.xs) {
                    Text(product.price.formatted)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    Text("· Stock: \(product.stockQuantity)")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(product.isLowStock ? AppTheme.Colors.warning : .secondary)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { product.isActive },
                set: { _ in viewModel.toggleProductActive(product) }
            ))
            .tint(AppTheme.Colors.success)
            .labelsHidden()
            .scaleEffect(0.8)
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteProduct(product)
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(AppTheme.Colors.primary)
            Button {
                viewModel.duplicateProduct(product)
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc.fill")
            }
            .tint(AppTheme.Colors.secondary)
        }
    }
}
