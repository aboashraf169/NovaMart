import SwiftUI
import PhotosUI

struct AddEditProductView: View {
    let product: Product?
    let onSave: (Product) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var longDescription = ""
    @State private var brand = ""
    @State private var sku = ""
    @State private var price: String = ""
    @State private var compareAtPrice: String = ""
    @State private var costPrice: String = ""
    @State private var stockQuantity: String = ""
    @State private var selectedCategory: Category = Category.allCategories[0]
    @State private var tags: String = ""
    @State private var isFeatured = false
    @State private var isActive = true
    @State private var isFlashSale = false
    @State private var flashSaleEndsAt = Date.now.addingTimeInterval(86400)
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var pickedImages: [UIImage] = []
    @State private var validationError: String? = nil
    @State private var isSaving = false

    var isEditing: Bool { product != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Product Name *", text: $name)
                    TextField("Brand *", text: $brand)
                    TextField("SKU *", text: $sku)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Category.allCategories) { cat in
                            Text(cat.name).tag(cat)
                        }
                    }
                }
                .listRowBackground(Color.clear)

                Section {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("IMAGES")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)

                        let existingImages = product?.images ?? []
                        let allImages: [(id: String, uiImage: UIImage?, url: String?)] =
                            existingImages.map { (id: $0.id.uuidString, uiImage: nil, url: $0.url) } +
                            pickedImages.enumerated().map { (id: "picked_\($0.offset)", uiImage: $0.element, url: nil) }

                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: AppSpacing.sm) {
                            // Image tiles
                            ForEach(allImages, id: \.id) { item in
                                ZStack(alignment: .topTrailing) {
                                    Group {
                                        if let uiImg = item.uiImage {
                                            Image(uiImage: uiImg)
                                                .resizable()
                                                .scaledToFill()
                                        } else if let url = item.url {
                                            AsyncImage(url: URL(string: url)) { img in
                                                img.resizable().scaledToFill()
                                            } placeholder: {
                                                Color.gray.opacity(0.15)
                                                    .overlay(ProgressView())
                                            }
                                        }
                                    }
                                    .frame(height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                                    )

                                    // Remove button (only for picked images)
                                    if item.uiImage != nil,
                                       let idx = pickedImages.firstIndex(where: { img in
                                           item.id == "picked_\(pickedImages.firstIndex(of: img) ?? -1)"
                                       }) {
                                        Button {
                                            pickedImages.remove(at: idx)
                                            selectedPhotos.remove(at: idx)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .black.opacity(0.65))
                                                .font(.system(size: 20))
                                        }
                                        .padding(4)
                                    }
                                }
                            }

                            // Add button tile
                            if allImages.count < 6 {
                                PhotosPicker(
                                    selection: $selectedPhotos,
                                    maxSelectionCount: 6 - existingImages.count,
                                    matching: .images
                                ) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundStyle(AppTheme.Colors.primary)
                                        Text("Add Photo")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(AppTheme.Colors.primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 100)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppTheme.Colors.primary.opacity(0.08))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(AppTheme.Colors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                    )
                                }
                                .onChange(of: selectedPhotos) { _, newItems in
                                    Task {
                                        var loaded: [UIImage] = []
                                        for item in newItems {
                                            if let data = try? await item.loadTransferable(type: Data.self),
                                               let img = UIImage(data: data) {
                                                loaded.append(img)
                                            }
                                        }
                                        pickedImages = loaded
                                    }
                                }
                            }
                        }

                        if !allImages.isEmpty {
                            Text("\(allImages.count)/6 photos")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, AppSpacing.xs)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                Section("Description") {
                    TextField("Short description *", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Long description", text: $longDescription, axis: .vertical)
                        .lineLimit(5...10)
                    TextField("Tags (comma separated)", text: $tags)
                }
                .listRowBackground(Color.clear)

                Section("Pricing") {
                    HStack {
                        Text("$")
                        TextField("Price *", text: $price)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("$")
                        TextField("Compare-at price (optional)", text: $compareAtPrice)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("$")
                        TextField("Cost price (admin only)", text: $costPrice)
                            .keyboardType(.decimalPad)
                    }
                }
                .listRowBackground(Color.clear)

                Section("Inventory") {
                    TextField("Stock Quantity *", text: $stockQuantity)
                        .keyboardType(.numberPad)
                }
                .listRowBackground(Color.clear)

                Section("Status") {
                    Toggle("Active", isOn: $isActive)
                    Toggle("Featured", isOn: $isFeatured)
                    Toggle("Flash Sale", isOn: $isFlashSale)
                    if isFlashSale {
                        DatePicker("Sale Ends", selection: $flashSaleEndsAt, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                    }
                }
                .listRowBackground(Color.clear)

                if let error = validationError {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppTheme.Colors.error)
                            .font(AppTheme.Typography.bodySmall)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AnimatedMeshBackground())
            .navigationTitle(isEditing ? "Edit Product" : "New Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSaving ? "Saving..." : "Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .disabled(isSaving)
                }
            }
            .onAppear { populate() }
        }
    }

    private func populate() {
        guard let p = product else { return }
        name = p.name; description = p.description; longDescription = p.longDescription
        brand = p.brand; sku = p.sku
        price = "\(NSDecimalNumber(decimal: p.price).doubleValue)"
        compareAtPrice = p.compareAtPrice.map { "\(NSDecimalNumber(decimal: $0).doubleValue)" } ?? ""
        costPrice = p.costPrice.map { "\(NSDecimalNumber(decimal: $0).doubleValue)" } ?? ""
        stockQuantity = "\(p.stockQuantity)"
        selectedCategory = p.category
        tags = p.tags.joined(separator: ", ")
        isFeatured = p.isFeatured; isActive = p.isActive
        isFlashSale = p.flashSaleEnds != nil
        flashSaleEndsAt = p.flashSaleEnds ?? Date.now.addingTimeInterval(86400)
    }

    private func buildImages() -> [ProductImage] {
        // Keep existing images, then append newly picked ones as local data URLs
        var result = product?.images ?? []
        for (index, img) in pickedImages.enumerated() {
            if let data = img.jpegData(compressionQuality: 0.8) {
                let base64 = "data:image/jpeg;base64," + data.base64EncodedString()
                result.append(ProductImage(
                    id: UUID(),
                    url: base64,
                    altText: "Product image \(result.count + index + 1)",
                    sortOrder: result.count + index
                ))
            }
        }
        return result
    }

    private func save() {
        validationError = nil

        guard !name.isEmpty else { validationError = "Product name is required."; return }
        guard !brand.isEmpty else { validationError = "Brand is required."; return }
        guard !sku.isEmpty else { validationError = "SKU is required."; return }
        guard let priceDecimal = Decimal(string: price), priceDecimal > 0 else {
            validationError = "Please enter a valid price."
            return
        }
        guard let stock = Int(stockQuantity) else { validationError = "Please enter a valid stock quantity."; return }

        isSaving = true
        HapticService.shared.play(.impact(.medium))

        let saved = Product(
            id: product?.id ?? UUID(),
            name: name,
            description: description,
            longDescription: longDescription,
            price: priceDecimal,
            compareAtPrice: Decimal(string: compareAtPrice),
            costPrice: Decimal(string: costPrice),
            images: buildImages(),
            variants: product?.variants ?? [],
            category: selectedCategory,
            tags: tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            rating: product?.rating ?? 0,
            reviewCount: product?.reviewCount ?? 0,
            soldCount: product?.soldCount ?? 0,
            stockQuantity: stock,
            sku: sku,
            barcode: product?.barcode,
            weight: product?.weight,
            isFeatured: isFeatured,
            isActive: isActive,
            discountPercent: nil,
            flashSaleEnds: isFlashSale ? flashSaleEndsAt : nil,
            brand: brand,
            metaTitle: nil,
            metaDescription: nil,
            createdAt: product?.createdAt ?? Date.now,
            updatedAt: Date.now
        )

        onSave(saved)
        HapticService.shared.play(.notification(.success))
        dismiss()
    }
}
