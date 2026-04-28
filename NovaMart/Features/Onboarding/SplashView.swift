import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var wordmarkOpacity: Double = 0
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: AppSpacing.lg) {
                // Logo mark
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primaryGradient)
                        .frame(width: 100, height: 100)
                        .shadow(color: AppTheme.Colors.primary.opacity(0.5), radius: 30)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Wordmark
                VStack(spacing: 4) {
                    Text("NovaMart")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("Shop the future")
                        .font(AppTheme.Typography.bodySmall)
                        .foregroundStyle(.secondary)
                        .tracking(3)
                        .textCase(.uppercase)
                }
                .opacity(wordmarkOpacity)
            }
        }
        .onAppear {
            animate()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingFlow()
        }
    }

    private func animate() {
        withAnimation(.bouncy.delay(0.3)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        withAnimation(.smooth.delay(0.6)) {
            wordmarkOpacity = 1.0
        }
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            await MainActor.run {
                withAnimation {
                    showOnboarding = true
                }
            }
        }
    }
}
