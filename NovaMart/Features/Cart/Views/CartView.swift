import SwiftUI

struct CartView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = CartViewModel()
    @State private var showCheckout = false

    var body: some View {
        Group {
            if appState.cartItems.isEmpty {
                EmptyCartView()
            } else {
                CartContentView(viewModel: viewModel, showCheckout: $showCheckout)
            }
        }
        .navigationTitle("Cart")
        .navigationBarTitleDisplayMode(.large)
        .background(AnimatedMeshBackground())
        .fullScreenCover(isPresented: $showCheckout) {
            CheckoutContainerView()
        }
    }
}

struct EmptyCartView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "bag")
                .font(.system(size: 80, weight: .thin))
                .foregroundStyle(AppTheme.Colors.primary.opacity(0.4))
                .symbolEffect(.pulse)

            VStack(spacing: AppSpacing.sm) {
                Text("Your cart is empty")
                    .font(AppTheme.Typography.title2)
                Text("Add items you love to get started")
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(.secondary)
            }

            GlassButton("Start Shopping", icon: "sparkles") {
                appState.selectedTab = .home
            }
            .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CartContentView: View {
    @Bindable var viewModel: CartViewModel
    @Binding var showCheckout: Bool
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Item count header
                HStack {
                    Text("\(appState.cartItemCount) item\(appState.cartItemCount == 1 ? "" : "s")")
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Clear All") {
                        withAnimation(.smooth) { appState.clearCart() }
                        HapticService.shared.play(.impact(.heavy))
                    }
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.error)
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                // Cart items
                ForEach(appState.cartItems) { item in
                    CartItemRow(item: item)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }

                // Coupon
                CouponFieldView(viewModel: viewModel)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Upsell
                CartUpsellSection()
                    .padding(.top, AppSpacing.sm)

                // Price summary
                PriceSummaryView(viewModel: viewModel)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Checkout button
                GlassButton("Checkout", icon: "arrow.right", style: .primary) {
                    showCheckout = true
                    HapticService.shared.play(.impact(.heavy))
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .buttonStyle(.glassProminent)

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .animation(.smooth, value: appState.cartItems.count)
    }
}

struct CartItemRow: View {
    let item: CartItem
    @Environment(AppState.self) private var appState
    @State private var quantity: Int

    init(item: CartItem) {
        self.item = item
        _quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            NavigationLink(destination: ProductDetailView(product: item.product)) {
                AsyncCachedImage(url: item.product.primaryImage?.url)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.product.name)
                    .font(AppTheme.Typography.labelMedium)
                    .lineLimit(2)

                if let variant = item.variant {
                    Text(variant.name)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                PriceView(price: item.unitPrice, compareAtPrice: nil, size: .small)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                // Line total
                Text(item.lineTotal.formatted)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))

                // Quantity stepper
                HStack(spacing: AppSpacing.xs) {
                    Button {
                        if quantity > 1 {
                            quantity -= 1
                            updateQuantity()
                            HapticService.shared.play(.selection)
                        } else {
                            removeItem()
                        }
                    } label: {
                        Image(systemName: quantity > 1 ? "minus" : "trash.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(quantity > 1 ? .primary : AppTheme.Colors.error)
                            .frame(width: 26, height: 26)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(ScalePressEffect())

                    Text("\(quantity)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .frame(minWidth: 20, alignment: .center)
                        .contentTransition(.numericText())

                    Button {
                        quantity += 1
                        updateQuantity()
                        HapticService.shared.play(.selection)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .semibold))
                            .frame(width: 26, height: 26)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(ScalePressEffect())
                    .disabled(quantity >= (item.variant?.stock ?? item.product.stockQuantity))
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .padding(.horizontal, AppSpacing.screenPadding)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                removeItem()
            } label: {
                Label("Remove", systemImage: "trash.fill")
            }
        }
    }

    private func updateQuantity() {
        if let idx = appState.cartItems.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.bouncy) {
                appState.cartItems[idx].quantity = quantity
            }
        }
    }

    private func removeItem() {
        HapticService.shared.play(.impact(.heavy))
        withAnimation(.smooth) {
            appState.removeFromCart(id: item.id)
        }
    }
}
