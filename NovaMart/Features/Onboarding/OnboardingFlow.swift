import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0
    @Namespace private var namespace

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "sparkles",
            gradient: [Color(hex: "#6E3AFF"), Color(hex: "#9B59FF")],
            title: "Curated for You",
            subtitle: "AI-powered recommendations that learn your style and surface exactly what you're looking for."
        ),
        OnboardingPage(
            icon: "shippingbox.fill",
            gradient: [Color(hex: "#00D4AA"), Color(hex: "#00A8FF")],
            title: "Lightning Fast Delivery",
            subtitle: "Same-day delivery in select cities. Track your order live, every step of the way."
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            gradient: [Color(hex: "#FF6B35"), Color(hex: "#FF2D55")],
            title: "Shop with Confidence",
            subtitle: "Secure payments, easy returns, and 24/7 customer support. We've got you covered."
        )
    ]

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.smooth, value: currentPage)

                // Bottom controls
                VStack(spacing: AppSpacing.xl) {
                    // Page indicators
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? AppTheme.Colors.primary : Color(UIColor.systemGray4))
                                .frame(width: i == currentPage ? 24 : 8, height: 8)
                                .animation(.bouncy, value: currentPage)
                        }
                    }

                    // CTA Button
                    if currentPage < pages.count - 1 {
                        GlassButton("Continue") {
                            withAnimation(.smooth) {
                                currentPage += 1
                            }
                            HapticService.shared.play(.selection)
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    } else {
                        VStack(spacing: AppSpacing.md) {
                            GlassButton("Get Started") {
                                appState.completeOnboarding()
                                HapticService.shared.play(.notification(.success))
                            }
                            .padding(.horizontal, AppSpacing.screenPadding)

                            Button("I already have an account") {
                                appState.completeOnboarding()
                            }
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.bottom, AppSpacing.xl)
                .padding(.top, AppSpacing.lg)
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let gradient: [Color]
    let title: String
    let subtitle: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: page.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 140, height: 140)
                    .shadow(color: page.gradient.first?.opacity(0.4) ?? .clear, radius: 40)

                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)

            // Text
            VStack(spacing: AppSpacing.md) {
                Text(page.title)
                    .font(AppTheme.Typography.display)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text(page.subtitle)
                    .font(AppTheme.Typography.bodyLarge)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, AppSpacing.xl)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer()
        }
        .onAppear {
            withAnimation(.bouncy.delay(0.1)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }
}
