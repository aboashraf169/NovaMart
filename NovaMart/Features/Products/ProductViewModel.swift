import SwiftUI
import Observation

@Observable
@MainActor
final class ProductViewModel {
    var products: [Product] = []
    var viewState: ViewState<[Product]> = .idle
    var filter: SearchFilter = .empty
    var currentPage = 1
    var hasMorePages = true
    var isLoadingMore = false

    private let service: ProductServiceProtocol

    init(service: ProductServiceProtocol = ProductService.shared) {
        self.service = service
    }

    func load() async {
        viewState = .loading
        currentPage = 1

        do {
            let fetched = try await service.fetchProducts(page: 1, filter: filter)
            if fetched.isEmpty {
                viewState = .empty
            } else {
                products = fetched
                viewState = .loaded(fetched)
            }
        } catch let error as AppError {
            viewState = .error(error)
        } catch {
            viewState = .error(.unknown(error.localizedDescription))
        }
    }

    func loadMore() async {
        guard hasMorePages, !isLoadingMore, case .loaded = viewState else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let next = try await service.fetchProducts(page: currentPage + 1, filter: filter)
            if next.isEmpty {
                hasMorePages = false
            } else {
                currentPage += 1
                products.append(contentsOf: next)
                viewState = .loaded(products)
            }
        } catch {
            // Silently fail for pagination
        }
    }

    func refresh() async {
        viewState = .idle
        await load()
    }

    func applyFilter() async {
        viewState = .idle
        currentPage = 1
        hasMorePages = true
        await load()
    }
}
