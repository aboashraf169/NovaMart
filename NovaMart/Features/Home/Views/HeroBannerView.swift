import SwiftUI

struct HeroBannerView: View {
    let products: [Product]
    let namespace: Namespace.ID
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Main card area
            ZStack {
                ForEach(Array(products.enumerated()), id: \.offset) { index, product in
                    HeroCard(product: product, namespace: namespace)
                        .opacity(currentIndex == index ? 1 : 0)
                        .scaleEffect(currentIndex == index ? 1 : 0.94)
                        .offset(x: currentIndex == index ? dragOffset : (index < currentIndex ? -30 : 30))
                        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: currentIndex)
                        .zIndex(currentIndex == index ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSpacing.heroBannerHeight)
            .gesture(
                DragGesture()
                    .onChanged { v in
                        dragOffset = v.translation.width * 0.3
                    }
                    .onEnded { v in
                        let threshold: CGFloat = 50
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if v.translation.width < -threshold && currentIndex < products.count - 1 {
                                currentIndex += 1
                            } else if v.translation.width > threshold && currentIndex > 0 {
                                currentIndex -= 1
                            }
                            dragOffset = 0
                        }
                    }
            )

            // Bottom thumbnail strip + dots
            HStack(spacing: AppSpacing.sm) {
                // Thumbnail previews
                HStack(spacing: 6) {
                    ForEach(Array(products.enumerated()), id: \.offset) { index, product in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentIndex = index
                            }
                        } label: {
                            AsyncCachedImage(url: product.primaryImage?.url) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(UIColor.systemGray5))
                            }
                            .frame(width: currentIndex == index ? 48 : 36, height: currentIndex == index ? 48 : 36)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(
                                        currentIndex == index ? AppTheme.Colors.primary : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .opacity(currentIndex == index ? 1 : 0.45)
                            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentIndex)
                        }
                        .buttonStyle(ScalePressEffect(scale: 0.93))
                    }
                }

                Spacer()

                // Counter badge
                Text("\(currentIndex + 1) / \(products.count)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xs)
        }
        .onReceive(timer) { _ in
            guard !products.isEmpty else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                currentIndex = (currentIndex + 1) % products.count
            }
        }
    }
}

// MARK: - Hero Card

struct HeroCard: View {
    let product: Product
    let namespace: Namespace.ID
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // Background image — full bleed
                    AsyncCachedImage(url: product.primaryImage?.url) {
                        Rectangle().fill(
                            LinearGradient(
                                colors: [Color(UIColor.systemGray5), Color(UIColor.systemGray4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                    // Multi-stop scrim
                    LinearGradient(
                        stops: [
                            .init(color: .black.opacity(0.08), location: 0.0),
                            .init(color: .clear, location: 0.35),
                            .init(color: .black.opacity(0.45), location: 0.62),
                            .init(color: .black.opacity(0.82), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Content overlay
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()

                        // Badge row
                        HStack(spacing: AppSpacing.xs) {
                            if product.isFlashSale {
                                Herobadge(text: "FLASH SALE", icon: "bolt.fill", color: AppTheme.Colors.accent)
                            } else if product.isFeatured {
                                Herobadge(text: "FEATURED", icon: "star.fill", color: AppTheme.Colors.primary)
                            }
                            Spacer()

                            // Action buttons
                            HStack(spacing: AppSpacing.xs) {
                                WishlistButton(productID: product.id)

                                Button {
                                    appState.addToCart(product)
                                    HapticService.shared.play(.impact(.medium))
                                } label: {
                                    Image(systemName: "bag.badge.plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(width: 40, height: 40)
                                        .background(.ultraThinMaterial, in: Circle())
                                }
                                .buttonStyle(ScalePressEffect())
                                .accessibilityLabel("Add \(product.name) to cart")
                            }
                        }
                        .padding(.bottom, AppSpacing.sm)

                        // Product name
                        Text(product.name)
                            .font(.system(size: 26, weight: .bold, design: .default))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                        // Brand + rating row
                        HStack(spacing: AppSpacing.sm) {
                            Text(product.brand)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.75))

                            if product.rating > 0 {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.yellow)
                                    Text(String(format: "%.1f", product.rating))
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                            }
                        }
                        .padding(.top, 4)

                        // Price row
                        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                            Text(product.price.formatted)
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.white)

                            if let compare = product.compareAtPrice {
                                Text(compare.formatted)
                                    .font(.system(size: 14, weight: .regular))
                                    .strikethrough()
                                    .foregroundStyle(.white.opacity(0.5))
                            }

                            if let pct = product.savingsPercent {
                                Text("-\(pct)%")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.Colors.accent, in: Capsule())
                            }
                        }
                        .padding(.top, AppSpacing.xs)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.lg)
                    .frame(width: geo.size.width, alignment: .leading)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, AppSpacing.screenPadding)
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hero Badge

private struct Herobadge: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(color, in: Capsule())
    }
}
