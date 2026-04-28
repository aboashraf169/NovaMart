import SwiftUI

struct ProductCardView: View {
    let product: Product
    var isTall: Bool = false
    @Environment(AppState.self) private var appState
    @State private var showQuickAdd = false
    @State private var isLongPressing = false

    var cardHeight: CGFloat {
        isTall ? AppSpacing.productCardMaxHeight : AppSpacing.productCardMinHeight
    }

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product)) {
            ZStack(alignment: .bottom) {
                // Product image
                AsyncCachedImage(url: product.primaryImage?.url)
                    .frame(maxWidth: .infinity)
                    .frame(height: cardHeight)

                // Corner ribbons
                VStack {
                    HStack {
                        if product.isLowStock {
                            CornerRibbon(text: "LOW STOCK", color: AppTheme.Colors.warning)
                        } else if product.isFlashSale {
                            CornerRibbon(text: "SALE", color: AppTheme.Colors.accent)
                        }
                        Spacer()
                        WishlistButton(productID: product.id)
                            .padding(AppSpacing.xs)
                    }
                    Spacer()
                }

                // Glass bottom overlay
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(AppTheme.Typography.labelSmall)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    HStack(alignment: .center) {
                        PriceView(price: product.price, compareAtPrice: product.compareAtPrice, size: .small)

                        Spacer()

                        RatingStarsView(rating: product.rating)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(.ultraThinMaterial)
            }
            .frame(height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.4) {
            HapticService.shared.play(.impact(.heavy))
            showQuickAdd = true
        }
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet(product: product, isPresented: $showQuickAdd)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
        .accessibilityLabel("\(product.name), \(product.price.formatted)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Product Grid View
struct ProductGridView: View {
    var filter: SearchFilter? = nil
    var title: String = "Products"
    @State private var viewModel = ProductViewModel()
    @State private var showFilter = false
    @State private var isListView = false

    var body: some View {
        Group {
            if isListView {
                ProductListView(viewModel: viewModel)
            } else {
                MasonryProductGrid(viewModel: viewModel)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .background(AnimatedMeshBackground())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: AppSpacing.sm) {
                    Button {
                        withAnimation(.snappy) { isListView.toggle() }
                        HapticService.shared.play(.selection)
                    } label: {
                        Image(systemName: isListView ? "square.grid.2x2.fill" : "list.bullet")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(.glass)

                    Button {
                        showFilter = true
                        HapticService.shared.play(.impact(.medium))
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .medium))
                            if viewModel.filter.activeFilterCount > 0 {
                                Circle()
                                    .fill(AppTheme.Colors.accent)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 5, y: -5)
                            }
                        }
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            FilterSheetView(filter: $viewModel.filter) {
                Task { await viewModel.applyFilter() }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
        }
        .task {
            if let filter { viewModel.filter = filter }
            await viewModel.load()
        }
    }
}

struct MasonryProductGrid: View {
    @Bindable var viewModel: ProductViewModel

    var body: some View {
        ScrollView {
            switch viewModel.viewState {
            case .loading, .idle:
                GridShimmer(columns: 2)
            case .loaded(let products):
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: AppSpacing.gridSpacing), GridItem(.flexible(), spacing: AppSpacing.gridSpacing)],
                    spacing: AppSpacing.gridSpacing
                ) {
                    ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                        ProductCardView(product: product, isTall: index % 3 == 0)
                            .staggeredAppear(index: index, delay: 0.04)
                            .onAppear {
                                if product.id == products.last?.id {
                                    Task { await viewModel.loadMore() }
                                }
                            }
                    }
                }
                .padding(AppSpacing.screenPadding)

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            case .empty:
                EmptyStateView(
                    icon: "tray.fill",
                    title: "No Products Found",
                    message: "Try adjusting your filters."
                )
            case .error(let error):
                ErrorRetryView(error: error) {
                    Task { await viewModel.load() }
                }
            }
        }
    }
}
