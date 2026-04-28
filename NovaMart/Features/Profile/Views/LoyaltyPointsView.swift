import SwiftUI

struct LoyaltyPointsView: View {
    let user: User
    @State private var showSpinWheel = false

    let achievements: [Achievement] = [
        Achievement(icon: "bag.fill", title: "First Purchase", description: "Made your first order", earned: true, points: 100),
        Achievement(icon: "star.fill", title: "Reviewer", description: "Left your first review", earned: true, points: 50),
        Achievement(icon: "person.2.fill", title: "Referral", description: "Referred a friend", earned: false, points: 200),
        Achievement(icon: "calendar", title: "1 Year Member", description: "Shopping for 1 year", earned: false, points: 500),
        Achievement(icon: "crown.fill", title: "Gold Status", description: "Reach Gold tier", earned: false, points: 1000)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Points hero
                VStack(spacing: AppSpacing.md) {
                    Text("\(user.loyaltyPoints.compactFormatted)")
                        .font(.system(size: 64, weight: .black, design: .monospaced))
                        .foregroundStyle(AppTheme.Colors.primaryGradient)
                        .contentTransition(.numericText())

                    Text("Total Points")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(.secondary)

                    HStack(spacing: AppSpacing.md) {
                        TierBadge(tier: .bronze, isCurrent: user.loyaltyTier == .bronze)
                        Image(systemName: "arrow.right").foregroundStyle(.secondary)
                        TierBadge(tier: .silver, isCurrent: user.loyaltyTier == .silver)
                        Image(systemName: "arrow.right").foregroundStyle(.secondary)
                        TierBadge(tier: .gold, isCurrent: user.loyaltyTier == .gold)
                        Image(systemName: "arrow.right").foregroundStyle(.secondary)
                        TierBadge(tier: .platinum, isCurrent: user.loyaltyTier == .platinum)
                    }
                }
                .padding(AppSpacing.xl)
                .glassCard()
                .padding(.horizontal, AppSpacing.screenPadding)

                // Spin wheel (birthday/milestone)
                Button {
                    showSpinWheel = true
                    HapticService.shared.play(.impact(.medium))
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppTheme.Colors.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Spin to Win!")
                                .font(AppTheme.Typography.labelLarge)
                            Text("1 spin available · Birthday reward")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.secondary)
                    }
                    .padding(AppSpacing.cardPadding)
                    .glassCard(tint: AppTheme.Colors.accent)
                }
                .buttonStyle(ScalePressEffect())
                .padding(.horizontal, AppSpacing.screenPadding)

                // Achievements
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Achievements")
                        .font(AppTheme.Typography.title3)
                        .padding(.horizontal, AppSpacing.screenPadding)

                    ForEach(achievements) { achievement in
                        AchievementRow(achievement: achievement)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }

                // How to earn
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("How to Earn Points")
                        .font(AppTheme.Typography.title3)
                        .padding(.horizontal, AppSpacing.screenPadding)

                    VStack(spacing: AppSpacing.sm) {
                        EarnRow(icon: "bag.fill", label: "Every purchase", value: "1 pt per $1")
                        EarnRow(icon: "star.fill", label: "Write a review", value: "50 pts")
                        EarnRow(icon: "person.2.fill", label: "Refer a friend", value: "200 pts")
                        EarnRow(icon: "birthday.cake.fill", label: "Birthday bonus", value: "2x pts")
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Loyalty Points")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showSpinWheel) {
            SpinWheelView()
                .presentationDetents([.large])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct TierBadge: View {
    let tier: LoyaltyTier
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(tier.gradient)
                    .frame(width: isCurrent ? 36 : 28, height: isCurrent ? 36 : 28)
                Image(systemName: "crown.fill")
                    .font(.system(size: isCurrent ? 14 : 11))
                    .foregroundStyle(.white)
            }
            Text(tier.rawValue.prefix(1).uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(isCurrent ? tier.color : .secondary)
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let earned: Bool
    let points: Int
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(achievement.earned ? AnyShapeStyle(AppTheme.Colors.primaryGradient) : AnyShapeStyle(Color(UIColor.systemGray5)))
                    .frame(width: 44, height: 44)
                Image(systemName: achievement.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(achievement.earned ? .white : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title).font(AppTheme.Typography.labelMedium)
                Text(achievement.description).font(AppTheme.Typography.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("+\(achievement.points)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(achievement.earned ? AppTheme.Colors.primary : .secondary)
                Text("pts")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            if achievement.earned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.Colors.success)
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
        .opacity(achievement.earned ? 1 : 0.6)
    }
}

struct EarnRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.Colors.primary)
                .frame(width: 24)
            Text(label).font(AppTheme.Typography.bodySmall)
            Spacer()
            Text(value)
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(AppTheme.Colors.primary)
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

struct SpinWheelView: View {
    @State private var rotation: Double = 0
    @State private var hasSpun = false
    @State private var prize: String? = nil
    @Environment(\.dismiss) private var dismiss

    let prizes = ["10% Off", "Free Ship", "50 Pts", "15% Off", "100 Pts", "5% Off", "200 Pts", "20% Off"]

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("Spin to Win!")
                .font(AppTheme.Typography.title1)
                .padding(.top, AppSpacing.xl)

            ZStack {
                ForEach(Array(prizes.enumerated()), id: \.offset) { index, prize in
                    WheelSlice(
                        prize: prize,
                        angle: Double(index) * (360 / Double(prizes.count)),
                        totalSlices: prizes.count,
                        color: index % 2 == 0 ? AppTheme.Colors.primary : AppTheme.Colors.secondary
                    )
                }
                // Center pin
                Circle()
                    .fill(.white)
                    .frame(width: 20, height: 20)
                    .shadow(radius: 4)
            }
            .frame(width: 280, height: 280)
            .rotationEffect(.degrees(rotation))

            if let result = prize {
                VStack(spacing: AppSpacing.sm) {
                    Text("🎉 You won!")
                        .font(AppTheme.Typography.title2)
                    Text(result)
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(AppTheme.Colors.primaryGradient)
                    GlassButton("Claim Reward") { dismiss() }
                        .frame(maxWidth: 200)
                }
            } else {
                GlassButton("Spin!", icon: "arrow.triangle.2.circlepath") {
                    spin()
                }
                .frame(maxWidth: 200)
                .disabled(hasSpun)
            }

            Spacer()
        }
        .padding(AppSpacing.screenPadding)
    }

    private func spin() {
        HapticService.shared.play(.impact(.heavy))
        let spins = Double.random(in: 5...8) * 360
        let landingAngle = Double.random(in: 0...360)

        withAnimation(.easeOut(duration: 3)) {
            rotation += spins + landingAngle
        }

        Task {
            try? await Task.sleep(for: .seconds(3.2))
            hasSpun = true
            prize = prizes.randomElement()
            HapticService.shared.play(.notification(.success))
        }
    }
}

struct WheelSlice: View {
    let prize: String
    let angle: Double
    let totalSlices: Int
    let color: Color

    var sliceAngle: Double { 360 / Double(totalSlices) }

    var body: some View {
        ZStack {
            PieSlice(startAngle: .degrees(angle), endAngle: .degrees(angle + sliceAngle))
                .fill(color.opacity(0.8))

            Text(prize)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(angle + sliceAngle / 2))
                .offset(x: 80 * cos((angle + sliceAngle / 2) * .pi / 180),
                        y: 80 * sin((angle + sliceAngle / 2) * .pi / 180))
        }
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        path.closeSubpath()
        return path
    }
}
