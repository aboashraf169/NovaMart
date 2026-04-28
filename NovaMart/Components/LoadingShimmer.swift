import SwiftUI

struct LoadingShimmer: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(0..<6, id: \.self) { _ in
                ShimmerRow()
            }
        }
        .padding(AppSpacing.screenPadding)
    }
}

struct ShimmerRow: View {
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ShimmerBox(width: 80, height: 80, cornerRadius: AppTheme.Radius.medium)
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ShimmerBox(width: 160, height: 14, cornerRadius: 7)
                ShimmerBox(width: 120, height: 12, cornerRadius: 6)
                ShimmerBox(width: 80, height: 16, cornerRadius: 8)
            }
            Spacer()
        }
        .padding(AppSpacing.cardPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }
}

struct ShimmerBox: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var phase: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(shimmerGradient)
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: 0),
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: max(0, phase - 0.3)),
                .init(color: Color(UIColor.systemGray4).opacity(0.9), location: phase),
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: min(1, phase + 0.3)),
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Grid Shimmer
struct GridShimmer: View {
    let columns: Int

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.gridSpacing), count: columns), spacing: AppSpacing.gridSpacing) {
            ForEach(0..<8, id: \.self) { i in
                ShimmerBox(
                    width: .infinity,
                    height: i % 2 == 0 ? 240 : 200,
                    cornerRadius: AppTheme.Radius.card
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(AppSpacing.screenPadding)
    }
}
