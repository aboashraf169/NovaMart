import SwiftUI
import Charts

struct RevenueChartView: View {
    let stats: DashboardStats
    @State private var selectedDay: DayRevenue? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Revenue — Last 30 Days")
                .font(AppTheme.Typography.labelLarge)

            Chart {
                ForEach(stats.revenueByDay) { day in
                    BarMark(
                        x: .value("Date", day.date, unit: .day),
                        y: .value("Revenue", NSDecimalNumber(decimal: day.revenue).doubleValue)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)

                    if let selected = selectedDay, selected.date == day.date {
                        RuleMark(x: .value("Date", day.date, unit: .day))
                            .foregroundStyle(.secondary.opacity(0.3))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            .annotation(position: .top) {
                                VStack(spacing: 2) {
                                    Text(day.date.dayMonthFormatted)
                                        .font(.system(size: 10, weight: .semibold))
                                    Text(day.revenue.formatted)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundStyle(AppTheme.Colors.primary)
                                }
                                .padding(6)
                                .glassCard(cornerRadius: AppTheme.Radius.small)
                            }
                    }
                }

                // Trend line
                ForEach(stats.revenueByDay) { day in
                    LineMark(
                        x: .value("Date", day.date, unit: .day),
                        y: .value("Revenue", NSDecimalNumber(decimal: day.revenue).doubleValue)
                    )
                    .foregroundStyle(AppTheme.Colors.accent.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(Decimal(v).formattedShort)
                                .font(.system(size: 10))
                        }
                    }
                }
            }
            .frame(height: 200)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { drag in
                                    let loc = drag.location
                                    if let date: Date = proxy.value(atX: loc.x) {
                                        selectedDay = stats.revenueByDay.min(by: {
                                            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                                        })
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.smooth) { selectedDay = nil }
                                }
                        )
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

struct TopProductsView: View {
    let stats: DashboardStats

    var maxRevenue: Double {
        stats.topSellingProducts.compactMap { NSDecimalNumber(decimal: $0.revenue).doubleValue }.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Top Products")
                .font(AppTheme.Typography.labelLarge)

            ForEach(Array(stats.topSellingProducts.prefix(5).enumerated()), id: \.element.id) { index, product in
                HStack(spacing: AppSpacing.md) {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundStyle(index < 3 ? AppTheme.Colors.accent : .secondary)
                        .frame(width: 20)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.productName)
                            .font(AppTheme.Typography.labelSmall)
                            .lineLimit(1)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(UIColor.systemGray5)).frame(height: 4)
                                Capsule()
                                    .fill(AppTheme.Colors.primaryGradient)
                                    .frame(width: geo.size.width * CGFloat(NSDecimalNumber(decimal: product.revenue).doubleValue / maxRevenue), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }

                    VStack(alignment: .trailing, spacing: 1) {
                        Text(product.revenue.formatted)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        Text("\(product.unitsSold) sold")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

struct RecentActivityFeed: View {
    let orders: [Order]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Recent Orders")
                .font(AppTheme.Typography.labelLarge)

            ForEach(orders.prefix(5)) { order in
                HStack(spacing: AppSpacing.md) {
                    // Status dot
                    Circle()
                        .fill(order.status.color)
                        .frame(width: 8, height: 8)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(order.orderNumber)
                            .font(AppTheme.Typography.labelSmall)
                        Text(order.customer.name)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        Text(order.total.formatted)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        Text(order.createdAt.relativeFormatted)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }

                    OrderStatusBadge(status: order.status)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}
