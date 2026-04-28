import SwiftUI

@main
struct NovaMartApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(appState.preferredColorScheme)
                .environment(\.locale, appState.language.locale)
                .environment(\.layoutDirection, appState.language.layoutDirection)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                if appState.isAuthenticated {
                    if appState.isAdmin {
                        AdminDashboardView()
                    } else {
                        MainTabView()
                    }
                } else {
                    AuthContainerView()
                }
            } else {
                SplashView()
            }
        }
        .animation(.smooth, value: appState.isAuthenticated)
        .animation(.smooth, value: appState.hasCompletedOnboarding)
        .overlay(alignment: .bottom) {
            ToastView()
        }
        .onOpenURL { url in
            appState.handleDeepLink(url)
        }
    }
}
