import SwiftUI

struct OrderStatusBadge: View {
    let status: OrderStatus

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.icon)
                .font(.system(size: 10, weight: .semibold))
            Text(status.displayName)
                .font(AppTheme.Typography.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(status.color.opacity(0.12), in: Capsule())
    }
}
