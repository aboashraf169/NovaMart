import SwiftUI

struct EditProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProfileViewModel()
    @State private var name = ""
    @State private var phone = ""

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Avatar
                VStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primaryGradient)
                            .frame(width: 88, height: 88)
                        Text(appState.currentUser?.initials ?? "?")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(.white)
                    }
                    Button("Change Photo") {}
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: AppSpacing.md) {
                    AuthField(title: "Full Name", text: $name, icon: "person.fill", type: .name)
                    AuthField(title: "Phone Number", text: $phone, icon: "phone.fill", type: .telephoneNumber)

                    // Email (read-only)
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Email")
                            .font(AppTheme.Typography.labelSmall)
                            .foregroundStyle(.secondary)
                        HStack {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            Text(appState.currentUser?.email ?? "")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .frame(height: AppSpacing.inputHeight)
                        .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                    }
                }

                GlassButton("Save Changes", icon: "checkmark", isLoading: viewModel.isLoading) {
                    Task {
                        await viewModel.updateProfile(name: name, phone: phone, appState: appState)
                        dismiss()
                    }
                }
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = appState.currentUser?.name ?? ""
            phone = appState.currentUser?.phone ?? ""
        }
    }
}
