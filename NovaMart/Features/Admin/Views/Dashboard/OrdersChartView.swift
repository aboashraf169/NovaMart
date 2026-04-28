import SwiftUI
import Charts

struct OrdersChartView: View {
    let stats: DashboardStats

    @State private var selectedStatus: OrderStatus? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Orders by Status")
                .font(AppTheme.Typography.labelLarge)

            Chart(stats.ordersByStatus, id: \.status) { item in
                SectorMark(
                    angle: .value("Orders", item.count),
                    innerRadius: .ratio(0.58),
                    angularInset: 2
                )
                .foregroundStyle(item.status.color)
                .cornerRadius(4)
                .opacity(selectedStatus == nil || selectedStatus == item.status ? 1 : 0.35)
            }
            .chartAngleSelection(value: $selectedStatus)
            .frame(height: 200)
            .chartBackground { _ in
                if let selected = selectedStatus {
                    VStack(spacing: 2) {
                        Text(selected.displayName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                        let count = stats.ordersByStatus.first(where: { $0.status == selected })?.count ?? 0
                        Text("\(count)")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .contentTransition(.numericText())
                    }
                } else {
                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("\(stats.totalOrders)")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                    }
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                ForEach(stats.ordersByStatus, id: \.status) { item in
                    Button {
                        withAnimation(.snappy) {
                            selectedStatus = selectedStatus == item.status ? nil : item.status
                        }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Circle()
                                .fill(item.status.color)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.status.displayName)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text("\(item.count)")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundStyle(item.status.color)
                            }
                            Spacer()
                        }
                        .padding(AppSpacing.sm)
                        .glassCard(tint: selectedStatus == item.status ? item.status.color : nil)
                    }
                    .buttonStyle(ScalePressEffect())
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}

struct OrderVolumeTrendView: View {
    let stats: DashboardStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Order Volume — Last 30 Days")
                .font(AppTheme.Typography.labelLarge)

            Chart(stats.revenueByDay) { day in
                AreaMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Orders", day.orderCount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.Colors.secondary.opacity(0.6), AppTheme.Colors.secondary.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Orders", day.orderCount)
                )
                .foregroundStyle(AppTheme.Colors.secondary)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
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
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(.system(size: 10))
                        }
                    }
                }
            }
            .frame(height: 160)
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .padding(.horizontal, AppSpacing.screenPadding)
    }
}
