import SwiftUI

struct StatsGridView: View {
    let stats: DashboardStats

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
            KPICard(
                title: "Revenue",
                value: stats.totalRevenue.formattedShort,
                delta: stats.revenueGrowth,
                icon: "dollarsign.circle.fill",
                color: AppTheme.Colors.primary,
                sparkline: stats.revenueByDay.suffix(7).map { NSDecimalNumber(decimal: $0.revenue).doubleValue }
            )
            KPICard(
                title: "Orders",
                value: stats.totalOrders.compactFormatted,
                delta: stats.ordersGrowth,
                icon: "shippingbox.fill",
                color: AppTheme.Colors.secondary,
                sparkline: (0..<7).map { _ in Double.random(in: 20...60) }
            )
            KPICard(
                title: "Customers",
                value: stats.totalCustomers.compactFormatted,
                delta: stats.returningCustomerRate * 100,
                icon: "person.2.fill",
                color: AppTheme.Colors.accent,
                sparkline: (0..<7).map { _ in Double.random(in: 100...500) }
            )
            KPICard(
                title: "Avg Order",
                value: stats.avgOrderValue.formatted,
                delta: 5.2,
                icon: "cart.fill",
                color: Color(hex: "#FFD700"),
                sparkline: (0..<7).map { _ in Double.random(in: 60...90) }
            )
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

struct KPICard: View {
    let title: String
    let value: String
    let delta: Double
    let icon: String
    let color: Color
    let sparkline: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Spacer()
                // Delta badge
                HStack(spacing: 2) {
                    Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 9, weight: .bold))
                    Text("\(String(format: "%.1f", abs(delta)))%")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(delta >= 0 ? AppTheme.Colors.success : AppTheme.Colors.error)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background((delta >= 0 ? AppTheme.Colors.success : AppTheme.Colors.error).opacity(0.12), in: Capsule())
            }

            Text(value)
                .font(.system(size: 24, weight: .black, design: .monospaced))
                .foregroundStyle(.primary)

            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)

            // Mini sparkline
            SparklineView(data: sparkline, color: color)
                .frame(height: 28)
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

// MARK: - Mini sparkline using Canvas
struct SparklineView: View {
    let data: [Double]
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            guard data.count > 1 else { return }
            let minV = data.min() ?? 0
            let maxV = data.max() ?? 1
            let range = maxV - minV == 0 ? 1 : maxV - minV
            let step = size.width / CGFloat(data.count - 1)

            var path = Path()
            for (i, value) in data.enumerated() {
                let x = CGFloat(i) * step
                let y = size.height - ((CGFloat(value) - CGFloat(minV)) / CGFloat(range)) * size.height
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}
