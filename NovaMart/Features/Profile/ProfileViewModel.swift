import SwiftUI
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var isLoading = false
    var showSignOutConfirm = false

    func updateProfile(name: String, phone: String, appState: AppState) async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(for: .milliseconds(600))
        appState.currentUser?.name = name
        appState.currentUser?.phone = phone
        HapticService.shared.play(.notification(.success))
        appState.showToast("Profile updated", style: .success)
    }

    func signOut(appState: AppState) {
        appState.signOut()
        HapticService.shared.play(.notification(.success))
    }
}
