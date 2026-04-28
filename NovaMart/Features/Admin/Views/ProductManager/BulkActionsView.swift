import SwiftUI

struct BulkActionsView: View {
    @Bindable var viewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIDs: Set<UUID> = []
    @State private var showConfirmDelete = false
    @State private var actionInProgress = false
    @State private var searchQuery = ""

    private var filtered: [Product] {
        guard !searchQuery.isEmpty else { return viewModel.products }
        return viewModel.products.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    private var allSelected: Bool { selectedIDs.count == filtered.count && !filtered.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GlassSearchBar(text: $searchQuery, placeholder: "Search products...")
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, AppSpacing.sm)

                if !selectedIDs.isEmpty {
                    actionBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                ScrollView {
                    LazyVStack(spacing: AppSpacing.xs) {
                        ForEach(filtered) { product in
                            BulkProductRow(
                                product: product,
                                isSelected: selectedIDs.contains(product.id)
                            ) {
                                toggleSelection(product.id)
                            }
                            .padding(.horizontal, AppSpacing.screenPadding)
                        }
                    }
                    .padding(.vertical, AppSpacing.md)
                }
            }
            .background(AnimatedMeshBackground())
            .navigationTitle("Bulk Actions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(allSelected ? "Deselect All" : "Select All") {
                        withAnimation(.snappy) {
                            if allSelected {
                                selectedIDs.removeAll()
                            } else {
                                selectedIDs = Set(filtered.map(\.id))
                            }
                        }
                        HapticService.shared.play(.selection)
                    }
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.primary)
                }
            }
            .animation(.smooth, value: selectedIDs.isEmpty)
            .confirmationDialog(
                "Delete \(selectedIDs.count) products?",
                isPresented: $showConfirmDelete,
                titleVisibility: .visible
            ) {
                Button("Delete \(selectedIDs.count) Products", role: .destructive) {
                    performDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("\(selectedIDs.count) selected")
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                performSetActive(true)
            } label: {
                Label("Activate", systemImage: "checkmark.circle")
                    .font(AppTheme.Typography.labelSmall)
            }
            .buttonStyle(.glass)

            Button {
                performSetActive(false)
            } label: {
                Label("Deactivate", systemImage: "xmark.circle")
                    .font(AppTheme.Typography.labelSmall)
            }
            .buttonStyle(.glass)

            Button {
                showConfirmDelete = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.error)
            }
            .buttonStyle(.glass)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.sm)
        .background(.ultraThinMaterial)
    }

    private func toggleSelection(_ id: UUID) {
        withAnimation(.snappy) {
            if selectedIDs.contains(id) {
                selectedIDs.remove(id)
            } else {
                selectedIDs.insert(id)
            }
        }
        HapticService.shared.play(.selection)
    }

    private func performSetActive(_ active: Bool) {
        withAnimation(.smooth) {
            for id in selectedIDs {
                if let idx = viewModel.products.firstIndex(where: { $0.id == id }) {
                    viewModel.products[idx].isActive = active
                }
            }
            selectedIDs.removeAll()
        }
        HapticService.shared.play(.notification(.success))
    }

    private func performDelete() {
        withAnimation(.smooth) {
            viewModel.products.removeAll { selectedIDs.contains($0.id) }
            selectedIDs.removeAll()
        }
        HapticService.shared.play(.notification(.success))
    }
}

private struct BulkProductRow: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? AppTheme.Colors.primary : Color(UIColor.separator), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 14, height: 14)
                    }
                }
                .animation(.snappy, value: isSelected)

                AsyncCachedImage(url: product.images.first?.url) {
                    Rectangle().fill(Color(UIColor.systemGray5))
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small))

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(AppTheme.Typography.labelSmall)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    HStack(spacing: AppSpacing.sm) {
                        Text(product.price.formatted)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AppTheme.Colors.primary)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text("\(product.stockQuantity) in stock")
                            .font(.system(size: 11))
                            .foregroundStyle(product.isLowStock ? AppTheme.Colors.warning : .secondary)
                    }
                }

                Spacer()

                if !product.isActive {
                    GlassBadge(text: "Inactive", color: .secondary, size: .small)
                }
            }
            .padding(AppSpacing.cardPadding)
            .glassCard(tint: isSelected ? AppTheme.Colors.primary : nil)
        }
        .buttonStyle(ScalePressEffect())
    }
}
