import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Search bar
                GlassSearchBar(
                    text: $viewModel.query,
                    placeholder: "Search products, brands...",
                    onSubmit: { viewModel.submitSearch() },
                    isFocused: false
                )
                .padding(.horizontal, AppSpacing.screenPadding)
                .onChange(of: viewModel.query) { _, newValue in
                    Task { await viewModel.performSearch() }
                }

                // Content
                if viewModel.query.isEmpty {
                    // Empty state: show recents + trending
                    VStack(spacing: AppSpacing.xl) {
                        if !viewModel.recentSearches.isEmpty {
                            RecentSearchesView(viewModel: viewModel)
                        }
                        TrendingSearchesView(viewModel: viewModel)
                    }
                } else {
                    SearchResultsView(viewModel: viewModel)
                }
            }
            .padding(.top, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
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
            ProgressView("Searching...")
                .padding()
        case .loaded(let products):
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("\(products.count) results for \"\(viewModel.query)\"")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, AppSpacing.screenPadding)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: AppSpacing.gridSpacing), GridItem(.flexible(), spacing: AppSpacing.gridSpacing)],
                    spacing: AppSpacing.gridSpacing
                ) {
                    ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                        ProductCardView(product: product, isTall: index % 3 == 0)
                            .staggeredAppear(index: index, delay: 0.04)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
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
