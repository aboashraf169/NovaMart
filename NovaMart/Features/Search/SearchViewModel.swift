import SwiftUI
import Observation

@Observable
@MainActor
final class SearchViewModel {
    var query: String = ""
    var results: [Product] = []
    var viewState: ViewState<[Product]> = .idle
    var recentSearches: [String] = []
    var trendingSearches: [String] = ["Wireless headphones", "Leather bags", "Yoga mat", "Coffee maker", "Running shoes", "Winter jacket", "Smart watch", "Skincare"]
    var isSearchActive = false

    private let service: ProductServiceProtocol
    private var searchTask: Task<Void, Never>? = nil

    init(service: ProductServiceProtocol = ProductService.shared) {
        self.service = service
        loadRecentSearches()
    }

    func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            viewState = .idle
            return
        }

        searchTask?.cancel()
        searchTask = Task {
            viewState = .loading

            // Debounce
            try? await Task.sleep(for: .milliseconds(200))
            guard !Task.isCancelled else { return }

            do {
                let found = try await service.search(query: trimmed, page: 1)
                guard !Task.isCancelled else { return }
                results = found
                viewState = found.isEmpty ? .empty : .loaded(found)
            } catch {
                guard !Task.isCancelled else { return }
                viewState = .error(.unknown(error.localizedDescription))
            }
        }
    }

    func submitSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        addRecentSearch(trimmed)
        Task { await performSearch() }
    }

    func selectTrending(_ term: String) {
        query = term
        addRecentSearch(term)
        Task { await performSearch() }
    }

    func removeRecent(_ term: String) {
        recentSearches.removeAll { $0 == term }
        saveRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }

    private func addRecentSearch(_ term: String) {
        recentSearches.removeAll { $0 == term }
        recentSearches.insert(term, at: 0)
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        saveRecentSearches()
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
}
