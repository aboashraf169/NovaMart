import SwiftUI

extension Animation {
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.85)
    static let smooth = Animation.spring(response: 0.5, dampingFraction: 0.9)
    static let elastic = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let quickBounce = Animation.spring(response: 0.25, dampingFraction: 0.65)
}

// MARK: - Stagger helper
struct StaggeredAppear: ViewModifier {
    let index: Int
    let delay: Double

    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.92)
            .offset(y: appeared ? 0 : 16)
            .onAppear {
                withAnimation(.smooth.delay(Double(index) * delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int, delay: Double = 0.06) -> some View {
        modifier(StaggeredAppear(index: index, delay: delay))
    }
}

// MARK: - Scale press effect
struct ScalePressEffect: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.quickBounce, value: configuration.isPressed)
    }
}

// MARK: - Shake modifier
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 4
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func shake(trigger: Bool) -> some View {
        modifier(ShakeEffect(animatableData: trigger ? 1 : 0))
    }
}

// MARK: - Pulse effect
struct PulseEffect: ViewModifier {
    @State private var pulsing = false
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(pulsing ? 0.6 : 0.2), radius: pulsing ? radius : radius / 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulsing = true
                }
            }
    }
}

extension View {
    func pulseEffect(color: Color = AppTheme.Colors.primary, radius: CGFloat = 12) -> some View {
        modifier(PulseEffect(color: color, radius: radius))
    }
}

// MARK: - Number ticker animation
struct NumberTickerModifier: AnimatableModifier {
    var number: Double
    let format: String

    nonisolated var animatableData: Double {
        get { number }
        set { number = newValue }
    }

    @MainActor
    func body(content: Content) -> some View {
        Text(String(format: format, number))
    }
}
