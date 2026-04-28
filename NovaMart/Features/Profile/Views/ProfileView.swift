import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ProfileViewModel()

    var user: User? { appState.currentUser }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Hero header
                ProfileHeroView(user: user)
                    .padding(.horizontal, AppSpacing.screenPadding)

                // Stats row
                if let user {
                    ProfileStatsRow(user: user)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Loyalty
                if let user {
                    NavigationLink(destination: LoyaltyPointsView(user: user)) {
                        LoyaltyCardView(user: user)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Settings groups
                VStack(spacing: AppSpacing.md) {
                    ProfileSection(title: "Account") {
                        ProfileRow(icon: "person.fill", label: "Edit Profile", color: AppTheme.Colors.primary) {
                            NavigationLink(destination: EditProfileView()) { EmptyView() }
                        }
                        ProfileRow(icon: "location.fill", label: "Address Book", color: AppTheme.Colors.secondary) {
                            NavigationLink(destination: AddressBookView()) { EmptyView() }
                        }
                        ProfileRow(icon: "creditcard.fill", label: "Payment Methods", color: AppTheme.Colors.accent) {
                            NavigationLink(destination: PaymentMethodsView()) { EmptyView() }
                        }
                    }

                    ProfileSection(title: "Preferences") {
                        ProfileRow(icon: "bell.fill", label: "Notifications", color: AppTheme.Colors.warning) {
                            NavigationLink(destination: NotificationsSettingsView()) { EmptyView() }
                        }
                        LanguagePickerRow()
                    }

                    ProfileSection(title: "Support") {
                        ProfileRow(icon: "questionmark.circle.fill", label: "Help Center", color: Color(hex: "#5AC8FA")) {
                            EmptyView()
                        }
                        ProfileRow(icon: "star.fill", label: "Rate NovaMart", color: Color(hex: "#FFD700")) {
                            EmptyView()
                        }
                        ProfileRow(icon: "doc.text.fill", label: "Privacy Policy", color: .secondary) {
                            EmptyView()
                        }
                    }

                    // Admin dashboard access
                    if appState.isAdmin {
                        ProfileSection(title: "Admin") {
                            ProfileRow(icon: "chart.bar.fill", label: "Admin Dashboard", color: AppTheme.Colors.primary) {
                                NavigationLink(destination: AdminDashboardView()) { EmptyView() }
                            }
                        }
                    }

                    // Sign out
                    Button {
                        viewModel.showSignOutConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(AppTheme.Colors.error)
                            Text("Sign Out")
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundStyle(AppTheme.Colors.error)
                            Spacer()
                        }
                        .padding(AppSpacing.cardPadding)
                        .glassCard()
                    }
                    .buttonStyle(ScalePressEffect())
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                Text("NovaMart v1.0.0")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out", isPresented: $viewModel.showSignOutConfirm) {
            Button("Sign Out", role: .destructive) {
                viewModel.signOut(appState: appState)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct ProfileHeroView: View {
    let user: User?

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Avatar with tier ring
            ZStack {
                Circle()
                    .fill(user?.loyaltyTier.gradient ?? LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                    .frame(width: 72, height: 72)

                Circle()
                    .fill(.background)
                    .frame(width: 64, height: 64)

                Circle()
                    .fill(AppTheme.Colors.primaryGradient)
                    .frame(width: 58, height: 58)
                    .overlay(
                        Text(user?.initials ?? "?")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(.white)
                    )
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(user?.name ?? "Guest")
                    .font(AppTheme.Typography.title3)
                Text(user?.email ?? "")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundStyle(.secondary)

                if let tier = user?.loyaltyTier {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(tier.color)
                        Text("\(tier.rawValue.capitalized) Member")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(tier.color)
                    }
                }
            }

            Spacer()
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

struct ProfileStatsRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 0) {
            StatCell(value: "12", label: "Orders")
            Divider().frame(height: 40)
            NavigationLink(destination: WishlistView()) {
                StatCell(value: "5", label: "Wishlist")
            }
            .buttonStyle(.plain)
            Divider().frame(height: 40)
            StatCell(value: "8", label: "Reviews")
        }
        .padding(.vertical, AppSpacing.sm)
        .glassCard()
    }
}

struct StatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(AppTheme.Colors.primary)
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LoyaltyCardView: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(user.loyaltyPoints.compactFormatted)")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundStyle(.primary)
                    Text("Loyalty Points")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(user.loyaltyTier.gradient)
                        .frame(width: 50, height: 50)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                }
            }

            // Tier progress
            if let nextTier = user.loyaltyTier.nextTier {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text(user.loyaltyTier.rawValue.capitalized)
                            .font(AppTheme.Typography.captionBold)
                            .foregroundStyle(user.loyaltyTier.color)
                        Spacer()
                        Text(nextTier.rawValue.capitalized)
                            .font(AppTheme.Typography.captionBold)
                            .foregroundStyle(nextTier.color)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(UIColor.systemGray5)).frame(height: 6)
                            Capsule()
                                .fill(LinearGradient(colors: [user.loyaltyTier.color, nextTier.color], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * user.tierProgress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(nextTier.pointsRequired - user.loyaltyPoints) points to \(nextTier.rawValue.capitalized)")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard(tint: user.loyaltyTier.color.opacity(0.05))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: [user.loyaltyTier.color.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        }
    }
}

struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(1)

            VStack(spacing: 0) {
                content()
            }
            .glassCard()
        }
    }
}

struct LanguagePickerRow: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppTheme.Colors.primary)
                    .frame(width: 32, height: 32)
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("Language")
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(.primary)

            Spacer()

            Picker("Language", selection: Binding(
                get: { appState.language },
                set: { appState.setLanguage($0) }
            )) {
                ForEach(AppState.AppLanguage.allCases, id: \.self) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.menu)
            .tint(.secondary)
        }
        .padding(AppSpacing.cardPadding)
    }
}

struct ProfileRow<Trailing: View>: View {
    let icon: String
    let label: String
    let color: Color
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(label)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(.primary)

            Spacer()

            trailing()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(AppSpacing.cardPadding)
    }
}
