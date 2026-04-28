import SwiftUI

struct OrderTrackingView: View {
    let order: Order

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Live status
                VStack(spacing: AppSpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Current Status")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: order.status.icon)
                                    .foregroundStyle(order.status.color)
                                Text(order.status.displayName)
                                    .font(AppTheme.Typography.title3)
                            }
                        }
                        Spacer()
                        if order.status.isActive {
                            Circle()
                                .fill(AppTheme.Colors.success)
                                .frame(width: 10, height: 10)
                                .pulseEffect(color: AppTheme.Colors.success, radius: 8)
                        }
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * order.status.progress, height: 6)
                                .animation(.smooth, value: order.status.progress)
                        }
                    }
                    .frame(height: 6)

                    // Estimated delivery
                    if let delivery = order.estimatedDelivery {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(AppTheme.Colors.secondary)
                            Text("Estimated: \(delivery.smartFormatted)")
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Tracking number
                if let tracking = order.trackingNumber {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tracking Number")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                            Text(tracking)
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        }
                        Spacer()
                        Button {
                            UIPasteboard.general.string = tracking
                            HapticService.shared.play(.notification(.success))
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc.fill")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.primary)
                        }
                    }
                    .padding(AppSpacing.cardPadding)
                    .glassCard()
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Timeline
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Shipment History")
                        .font(AppTheme.Typography.labelLarge)

                    VStack(spacing: 0) {
                        ForEach(Array(order.timeline.reversed().enumerated()), id: \.element.id) { index, event in
                            TimelineRow(
                                event: event,
                                isFirst: index == 0,
                                isLast: index == order.timeline.count - 1
                            )
                        }
                    }
                }
                .padding(AppSpacing.cardPadding)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Track Order")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TimelineRow: View {
    let event: OrderEvent
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // Dot + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isFirst ? event.status.color : Color(UIColor.systemGray5))
                        .frame(width: 20, height: 20)

                    if isFirst {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 20)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(event.message)
                    .font(isFirst ? AppTheme.Typography.labelMedium : AppTheme.Typography.bodySmall)
                    .foregroundStyle(isFirst ? .primary : .secondary)

                if let location = event.location {
                    Text(location)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Text(event.date.smartFormatted)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, AppSpacing.md)
        }
    }
}
