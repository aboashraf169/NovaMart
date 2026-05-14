import SwiftUI

struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let tint: Color?
    let padding: EdgeInsets
    @ViewBuilder let content: () -> Content

    init(
        cornerRadius: CGFloat = AppTheme.Radius.card,
        tint: Color? = nil,
        padding: EdgeInsets = EdgeInsets(top: AppSpacing.cardPadding, leading: AppSpacing.cardPadding, bottom: AppSpacing.cardPadding, trailing: AppSpacing.cardPadding),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .glassCard(cornerRadius: cornerRadius, tint: tint)
    }
}

#Preview {
    GlassCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Glass Card")
                .font(.headline)
            Text("This is a reusable glass-styled card component.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
