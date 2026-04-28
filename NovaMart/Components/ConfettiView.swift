import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let isActive: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiParticleView(particle: particle)
                }
            }
        }
        .onChange(of: isActive) { _, active in
            if active { launchConfetti() }
            else { particles = [] }
        }
        .allowsHitTesting(false)
    }

    private func launchConfetti() {
        particles = (0..<80).map { _ in ConfettiParticle() }
        Task {
            try? await Task.sleep(for: .seconds(4))
            await MainActor.run {
                withAnimation(.smooth) {
                    particles = []
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat = CGFloat.random(in: 0...1)
    let color: Color = [
        AppTheme.Colors.primary,
        AppTheme.Colors.secondary,
        AppTheme.Colors.accent,
        Color(hex: "#FFD700"),
        Color(hex: "#FF69B4"),
        Color(hex: "#00BFFF")
    ].randomElement()!
    let size: CGFloat = CGFloat.random(in: 6...14)
    let speed: Double = Double.random(in: 2...5)
    let angle: Double = Double.random(in: -30...30)
    let rotation: Double = Double.random(in: 0...360)
    let rotationSpeed: Double = Double.random(in: -180...180)
    let shape: ParticleShape = ParticleShape.allCases.randomElement()!

    enum ParticleShape: CaseIterable {
        case circle, square, triangle
    }
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    @State private var yOffset: CGFloat = -20
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geo in
            Group {
                switch particle.shape {
                case .circle:
                    Circle().fill(particle.color)
                case .square:
                    Rectangle().fill(particle.color).rotationEffect(.degrees(45))
                case .triangle:
                    Triangle().fill(particle.color)
                }
            }
            .frame(width: particle.size, height: particle.size)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .position(
                x: geo.size.width * particle.x,
                y: yOffset
            )
            .onAppear {
                withAnimation(.easeIn(duration: particle.speed)) {
                    yOffset = geo.size.height + 20
                }
                withAnimation(.easeIn(duration: particle.speed).delay(particle.speed * 0.6)) {
                    opacity = 0
                }
                withAnimation(.linear(duration: particle.speed).repeatForever(autoreverses: false)) {
                    rotation = particle.rotation + particle.rotationSpeed
                }
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
