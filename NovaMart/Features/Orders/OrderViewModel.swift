import SwiftUI
import Observation

@Observable
@MainActor
final class OrderViewModel {
    var orders: [Order] = []
    var viewState: ViewState<[Order]> = .idle
    var selectedStatus: OrderStatus? = nil

    func load() async {
        viewState = .loading
        try? await Task.sleep(for: .milliseconds(400))
        let filtered = selectedStatus.map { status in
            Order.samples.filter { $0.status == status }
        } ?? Order.samples
        orders = filtered
        viewState = orders.isEmpty ? .empty : .loaded(orders)
    }

    func filterByStatus(_ status: OrderStatus?) async {
        selectedStatus = status
        await load()
    }

    func cancelOrder(_ order: Order) async {
        if let idx = orders.firstIndex(where: { $0.id == order.id }) {
            orders[idx].status = .cancelled
            viewState = .loaded(orders)
        }
    }
}
