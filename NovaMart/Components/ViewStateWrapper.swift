import SwiftUI

enum ViewState<T: Sendable>: Sendable {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(AppError)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var loadedValue: T? {
        if case .loaded(let v) = self { return v }
        return nil
    }

    var error: AppError? {
        if case .error(let e) = self { return e }
        return nil
    }
}

struct ViewStateWrapper<T: Sendable, Content: View, EmptyContent: View>: View {
    let state: ViewState<T>
    let onRetry: (() -> Void)?
    let emptyTitle: String
    let emptyMessage: String
    let emptyIcon: String
    @ViewBuilder let content: (T) -> Content
    @ViewBuilder let emptyContent: () -> EmptyContent

    init(
        state: ViewState<T>,
        onRetry: (() -> Void)? = nil,
        emptyTitle: String = "Nothing Here",
        emptyMessage: String = "Check back later.",
        emptyIcon: String = "tray.fill",
        @ViewBuilder content: @escaping (T) -> Content,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent = { EmptyView() }
    ) {
        self.state = state
        self.onRetry = onRetry
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.emptyIcon = emptyIcon
        self.content = content
        self.emptyContent = emptyContent
    }

    var body: some View {
        switch state {
        case .idle, .loading:
            LoadingShimmer()
        case .loaded(let value):
            content(value)
        case .empty:
            EmptyStateView(
                icon: emptyIcon,
                title: emptyTitle,
                message: emptyMessage
            )
        case .error(let error):
            ErrorRetryView(error: error, onRetry: onRetry)
        }
    }
}
