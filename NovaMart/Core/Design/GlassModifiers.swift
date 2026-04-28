import SwiftUI

// MARK: - Glass card modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.Radius.card
    var tint: Color? = nil

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        if let tint {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(tint.opacity(0.08))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    }
            }
            .glassEffect(in: .rect(cornerRadius: cornerRadius))
    }
}

// MARK: - Floating action button glass
struct FloatingGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .glassEffect(.regular.interactive(), in: .circle)
    }
}

// MARK: - Glass overlay (for image overlays)
struct GlassOverlayModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.Radius.small
    var alignment: Alignment = .bottom

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
            }
    }
}

// MARK: - Glass badge
struct GlassBadgeModifier: ViewModifier {
    var tint: Color = .clear

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
    }
}

// MARK: - Bottom sheet glass
struct BottomSheetGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: AppTheme.Radius.sheet,
                    topTrailingRadius: AppTheme.Radius.sheet
                )
                .fill(.ultraThinMaterial)
                .overlay {
                    UnevenRoundedRectangle(
                        topLeadingRadius: AppTheme.Radius.sheet,
                        topTrailingRadius: AppTheme.Radius.sheet
                    )
                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                }
            }
            .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - View Extensions
extension View {
    func glassCard(cornerRadius: CGFloat = AppTheme.Radius.card, tint: Color? = nil) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, tint: tint))
    }

    func floatingGlass() -> some View {
        modifier(FloatingGlassModifier())
    }

    func glassOverlay(cornerRadius: CGFloat = AppTheme.Radius.small) -> some View {
        modifier(GlassOverlayModifier(cornerRadius: cornerRadius))
    }

    func glassBadge(tint: Color = .clear) -> some View {
        modifier(GlassBadgeModifier(tint: tint))
    }

    func bottomSheetGlass() -> some View {
        modifier(BottomSheetGlassModifier())
    }
}

// MARK: - Animated Mesh Background
struct AnimatedMeshBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var phase: Double = 0

    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: meshPoints,
            colors: AppTheme.meshColors(isDark: colorScheme == .dark, phase: phase)
        )
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 3)) {
                phase += 0.3
            }
        }
    }

    private var meshPoints: [SIMD2<Float>] {
        AppTheme.meshPoints(phase: phase)
    }
}
