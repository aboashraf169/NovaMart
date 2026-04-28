import SwiftUI

struct AuthContainerView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showLogin = true
    @Namespace private var namespace

    var body: some View {
        ZStack {
            AnimatedMeshBackground()

            VStack(spacing: 0) {
                // Logo
                VStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primaryGradient)
                            .frame(width: 64, height: 64)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.white)
                    }

                    Text("NovaMart")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .padding(.top, AppSpacing.xxxl)
                .padding(.bottom, AppSpacing.xl)

                // Auth tab selector
                GlassEffectContainer {
                    HStack(spacing: 0) {
                        AuthTabButton(title: "Sign In", isSelected: showLogin, namespace: namespace, id: "tab") {
                            withAnimation(.bouncy) { showLogin = true }
                        }
                        AuthTabButton(title: "Sign Up", isSelected: !showLogin, namespace: namespace, id: "tab") {
                            withAnimation(.bouncy) { showLogin = false }
                        }
                    }
                    .padding(4)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xl)

                // Content
                if showLogin {
                    LoginView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                } else {
                    RegisterView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

struct AuthTabButton: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let id: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.labelMedium)
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(.white.opacity(0.15))
                            .matchedGeometryEffect(id: id, in: namespace)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
