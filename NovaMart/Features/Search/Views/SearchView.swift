import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Search bar — always visible at top
            GlassSearchBar(
                text: $viewModel.query,
                placeholder: "Search products, brands...",
                onSubmit: { viewModel.submitSearch() },
                isFocused: false
            )
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.sm)
            .onChange(of: viewModel.query) { _, _ in
                Task { await viewModel.performSearch() }
            }

            // Content
            if viewModel.query.isEmpty {
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        if !viewModel.recentSearches.isEmpty {
                            RecentSearchesView(viewModel: viewModel)
                        }
                        TrendingSearchesView(viewModel: viewModel)
                    }
                    .padding(.top, AppSpacing.md)
                }
            } else {
                SearchResultsView(viewModel: viewModel)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct RecentSearchesView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recent")
                    .font(AppTheme.Typography.title3)
                Spacer()
                Button("Clear") {
                    viewModel.clearRecentSearches()
                    HapticService.shared.play(.impact(.light))
                }
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(AppTheme.Colors.error)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            VStack(spacing: AppSpacing.xs) {
                ForEach(viewModel.recentSearches, id: \.self) { term in
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        Button(term) {
                            viewModel.selectTrending(term)
                        }
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(.primary)

                        Spacer()

                        Button {
                            viewModel.removeRecent(term)
                            HapticService.shared.play(.impact(.light))
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, AppSpacing.xs)
                }
            }
        }
    }
}

struct TrendingSearchesView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(AppTheme.Colors.accent)
                Text("Trending")
                    .font(AppTheme.Typography.title3)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            VStack(spacing: AppSpacing.xs) {
                ForEach(Array(viewModel.trendingSearches.enumerated()), id: \.element) { index, term in
                    Button {
                        viewModel.selectTrending(term)
                        HapticService.shared.play(.selection)
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            Text("\(index + 1)")
                                .font(.system(size: 15, weight: .black, design: .monospaced))
                                .foregroundStyle(index < 3 ? AppTheme.Colors.accent : .secondary)
                                .frame(width: 24, alignment: .center)

                            Text(term)
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.vertical, AppSpacing.sm)
                    }
                    .buttonStyle(ScalePressEffect(scale: 0.98))
                }
            }
        }
    }
}

struct SearchResultsView: View {
    @Bindable var viewModel: SearchViewModel

    var body: some View {
        switch viewModel.viewState {
        case .loading:
            List {
                ForEach(0..<8, id: \.self) { _ in
                    SearchRowShimmer()
                }
            }
            .listStyle(.insetGrouped)
        case .loaded(let products):
            VStack(alignment: .leading, spacing: 0) {
                Text("\(products.count) results for \"\(viewModel.query)\"")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.bottom, AppSpacing.sm)

                List {
                    ForEach(products) { product in
                        SearchProductRow(product: product)
                    }
                }
                .listStyle(.insetGrouped)
                .frame(maxHeight: .infinity)
            }
        case .empty:
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "magnifyingglass.circle")
                    .font(.system(size: 56, weight: .thin))
                    .foregroundStyle(.secondary)

                VStack(spacing: AppSpacing.sm) {
                    Text("No results for \"\(viewModel.query)\"")
                        .font(AppTheme.Typography.title3)
                    Text("Try a different search term or browse by category.")
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Text("Trending searches")
                    .font(AppTheme.Typography.labelMedium)
                    .foregroundStyle(.secondary)

                FlowLayout(spacing: AppSpacing.sm) {
                    ForEach(Array(viewModel.trendingSearches.prefix(6)), id: \.self) { term in
                        Button(term) {
                            viewModel.selectTrending(term)
                        }
                        .font(AppTheme.Typography.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundStyle(.primary)
                    }
                }
            }
            .padding(AppSpacing.screenPadding)
        case .idle:
            EmptyView()
        case .error(let error):
            ErrorRetryView(error: error) {
                Task { await viewModel.performSearch() }
            }
        }
    }
}

// MARK: - Search Product Row

struct SearchProductRow: View {
    let product: Product
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationLink(destination: ProductDetailView(product: product))
        {
            HStack(spacing: 8) {
            // Thumnail
                AsyncCachedImage(url: product.primaryImage?.url)
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 100,maxHeight: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
                // Details
                VStack(alignment: .leading, spacing: 3) {
                    // Brand + wishlist toggle
                    HStack(alignment: .top) {
                        Text(product.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            appState.toggleWishlist(productID: product.id)
                            HapticService.shared.play(.impact(.light))
                        } label: {
                            Image(systemName: appState.isWishlisted(product.id) ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.pink)
                        }
                        .buttonStyle(ScalePressEffect())
                    }

                        Text(product.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
           

                    HStack(spacing: 3) {
                        RatingStarsView(rating: product.rating, size: 10)
                        Text(String(format: "%.1f", product.rating))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text("(\(product.reviewCount))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer(minLength: 4)

                    HStack(alignment: .center) {
                        HStack(alignment: .center, spacing: 10) {
                            Text("$\(product.price, format: .number.precision(.fractionLength(2)))")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    product.compareAtPrice != nil
                                    ? Color.red
                                    : AppTheme.Colors.primary
                                )
                            if let compare = product.compareAtPrice {
                                Text("$\(compare, format: .number.precision(.fractionLength(2)))")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                                    .strikethrough()
                            }
                        }
                        Spacer()
                        // Add to Cart — compact pill
                        Button {
                            appState.addToCart(product)
                            HapticService.shared.play(.notification(.success))
                        } label: {
                                Image(systemName: "bag.badge.plus")
                                    .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                product.isOutOfStock ? Color.secondary : AppTheme.Colors.primary,
                                in: Capsule()
                            )
                        }
                        .buttonStyle(ScalePressEffect())
                        .disabled(product.isOutOfStock)
                    }
                }
            }
       
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                appState.toggleWishlist(productID: product.id)
                HapticService.shared.play(.impact(.medium))
            } label: {
                Label(
                    appState.isWishlisted(product.id) ? "Unfavourite" : "Favourite",
                    systemImage: appState.isWishlisted(product.id) ? "heart.slash.fill" : "heart.fill"
                )
            }
            .tint(.pink)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                appState.addToCart(product)
                HapticService.shared.play(.notification(.success))
            } label: {
                Label("Add to Cart", systemImage: "bag.badge.plus")
            }
            .tint(AppTheme.Colors.primary)
        }
    }
}

// MARK: - Search Row Shimmer

private struct SearchRowShimmer: View {
    var body: some View {
        HStack(spacing: 12) {
            ShimmerBox(width: 90, height: 90, cornerRadius: 12)
            VStack(alignment: .leading, spacing: 8) {
                ShimmerBox(width: 100, height: 10, cornerRadius: 5)
                ShimmerBox(width: 160, height: 14, cornerRadius: 5)
                ShimmerBox(width: 80, height: 10, cornerRadius: 5)
                Spacer(minLength: 0)
                ShimmerBox(width: 60, height: 16, cornerRadius: 5)
            }
        }
        .frame(height: 90)
        .padding(.vertical, 4)
    }
}

// MARK: - Flow Layout for tag chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        height = y + rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environment(AppState())
}
