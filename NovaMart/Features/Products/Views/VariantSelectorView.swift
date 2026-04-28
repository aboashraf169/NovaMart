import SwiftUI

struct VariantSelectorView: View {
    let product: Product
    @Binding var selectedVariant: ProductVariant?

    private var colorOptions: [String] {
        Array(Set(product.variants.compactMap { $0.colorValue })).sorted()
    }
    private var sizeOptions: [String] {
        Array(Set(product.variants.compactMap { $0.sizeValue })).sorted()
    }

    @State private var selectedColor: String? = nil
    @State private var selectedSize: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Color picker
            if !colorOptions.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("Color")
                            .font(AppTheme.Typography.labelMedium)
                        if let color = selectedColor {
                            Text("· \(color)")
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(colorOptions, id: \.self) { color in
                                ColorSwatch(
                                    color: color,
                                    isSelected: selectedColor == color,
                                    isAvailable: isColorAvailable(color)
                                ) {
                                    HapticService.shared.play(.selection)
                                    withAnimation(.bouncy) {
                                        selectedColor = color
                                        updateSelectedVariant()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Size picker
            if !sizeOptions.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("Size")
                            .font(AppTheme.Typography.labelMedium)
                        if let size = selectedSize {
                            Text("· \(size)")
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Size Guide") {}
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.primary)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(sizeOptions, id: \.self) { size in
                                SizePill(
                                    size: size,
                                    isSelected: selectedSize == size,
                                    isAvailable: isSizeAvailable(size)
                                ) {
                                    HapticService.shared.play(.selection)
                                    withAnimation(.bouncy) {
                                        selectedSize = size
                                        updateSelectedVariant()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Single-option variants (no color/size)
            if colorOptions.isEmpty && sizeOptions.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Options")
                        .font(AppTheme.Typography.labelMedium)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(product.variants) { variant in
                                SizePill(
                                    size: variant.name,
                                    isSelected: selectedVariant?.id == variant.id,
                                    isAvailable: variant.isAvailable
                                ) {
                                    HapticService.shared.play(.selection)
                                    withAnimation(.bouncy) { selectedVariant = variant }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            selectedColor = colorOptions.first
            selectedSize = sizeOptions.first
            updateSelectedVariant()
        }
    }

    private func updateSelectedVariant() {
        selectedVariant = product.variants.first { variant in
            let colorMatch = selectedColor == nil || variant.colorValue == selectedColor
            let sizeMatch = selectedSize == nil || variant.sizeValue == selectedSize
            return colorMatch && sizeMatch
        }
    }

    private func isColorAvailable(_ color: String) -> Bool {
        product.variants.contains { $0.colorValue == color && $0.isAvailable }
    }

    private func isSizeAvailable(_ size: String) -> Bool {
        let matchingVariants = product.variants.filter { $0.sizeValue == size }
        return matchingVariants.contains { $0.isAvailable }
    }
}

struct ColorSwatch: View {
    let color: String
    let isSelected: Bool
    let isAvailable: Bool
    let action: () -> Void

    private var swatchColor: Color {
        let namedColors: [String: Color] = [
            "Black": .black, "White": .white,
            "Red": .red, "Blue": Color(hex: "#1A6BB0"),
            "Navy": Color(hex: "#000080"), "Forest": Color(hex: "#228B22"),
            "Tan": Color(hex: "#D2B48C"), "Cognac": Color(hex: "#9B4722"),
            "Oat": Color(hex: "#E8DCC8"), "Sage": Color(hex: "#87A878"),
            "Slate": Color(hex: "#708090"), "Purple": AppTheme.Colors.primary,
            "Midnight Blue": Color(hex: "#191970")
        ]
        return namedColors[color] ?? Color(hex: "#CCCCCC")
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(swatchColor)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().strokeBorder(.white.opacity(0.3), lineWidth: 0.5))

                if isSelected {
                    Circle()
                        .strokeBorder(AppTheme.Colors.primary, lineWidth: 2.5)
                        .frame(width: 44, height: 44)
                }

                if !isAvailable {
                    Circle()
                        .fill(.clear)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Path { path in
                                path.move(to: CGPoint(x: 8, y: 8))
                                path.addLine(to: CGPoint(x: 28, y: 28))
                            }
                            .stroke(.white.opacity(0.7), lineWidth: 2)
                        }
                }
            }
        }
        .buttonStyle(ScalePressEffect())
        .opacity(isAvailable ? 1 : 0.5)
        .accessibilityLabel("\(color)\(isAvailable ? "" : ", unavailable")\(isSelected ? ", selected" : "")")
    }
}

struct SizePill: View {
    let size: String
    let isSelected: Bool
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size)
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(isSelected ? .white : (isAvailable ? .primary : .secondary))
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background {
                    if isSelected {
                        Capsule().fill(AppTheme.Colors.primaryGradient)
                    } else {
                        Capsule().fill(.ultraThinMaterial)
                            .overlay(Capsule().strokeBorder(isAvailable ? Color.white.opacity(0.2) : Color.secondary.opacity(0.2), lineWidth: 0.5))
                    }
                }
                .overlay {
                    if !isAvailable {
                        Capsule()
                            .strokeBorder(Color.secondary.opacity(0.4), lineWidth: 1)
                        // Strikethrough simulation via diagonal
                    }
                }
        }
        .buttonStyle(ScalePressEffect())
        .opacity(isAvailable ? 1 : 0.5)
        .accessibilityLabel("\(size)\(isAvailable ? "" : ", unavailable")\(isSelected ? ", selected" : "")")
    }
}
