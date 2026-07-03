import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var previewLanguage: AppLanguage = .english

    private var l10n: L10n { L10n(language: previewLanguage) }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 28) {
                    hero
                    languageSection
                    featuresSection
                }
                .padding(.horizontal, 28)
                .padding(.top, 36)
                .padding(.bottom, 24)
            }

            footer
        }
        .frame(width: 440)
        .background(
            LinearGradient(
                colors: [AppTheme.canvas, AppTheme.surface],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .environment(\.layoutDirection, previewLanguage.layoutDirection)
        .onAppear {
            previewLanguage = settings.language
        }
    }

    private var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.softAccent.opacity(0.18),
                                AppTheme.softAccent.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Image(systemName: "network")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(AppTheme.softAccent)
            }

            VStack(spacing: 8) {
                Text(l10n.onboardingWelcome)
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(l10n.onboardingSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(l10n.chooseLanguage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.muted)

            HStack(spacing: 12) {
                ForEach(AppLanguage.allCases) { lang in
                    LanguageOptionCard(
                        language: lang,
                        isSelected: previewLanguage == lang
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            previewLanguage = lang
                        }
                    }
                }
            }
        }
    }

    private var featuresSection: some View {
        VStack(spacing: 10) {
            OnboardingFeatureRow(
                icon: "bolt.fill",
                title: l10n.onboardingFeature1Title,
                description: l10n.onboardingFeature1Desc
            )
            OnboardingFeatureRow(
                icon: "slider.horizontal.3",
                title: l10n.onboardingFeature2Title,
                description: l10n.onboardingFeature2Desc
            )
            OnboardingFeatureRow(
                icon: "globe",
                title: l10n.onboardingFeature3Title,
                description: l10n.onboardingFeature3Desc
            )
            OnboardingFeatureRow(
                icon: "bookmark.fill",
                title: l10n.onboardingFeature4Title,
                description: l10n.onboardingFeature4Desc
            )
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.5)

            Button {
                settings.language = previewLanguage
                withAnimation(.easeInOut(duration: 0.3)) {
                    settings.hasCompletedOnboarding = true
                }
            } label: {
                Text(l10n.getStarted)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.softAccent)
            .controlSize(.large)
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .background(.ultraThinMaterial)
        }
    }
}

private struct LanguageOptionCard: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(language == .english ? "🇬🇧" : "🇮🇷")
                    .font(.title)

                Text(language.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(language.nativeGreeting)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? AppTheme.softAccent.opacity(0.55) : AppTheme.hairline,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: .black.opacity(isSelected ? 0.07 : 0.03), radius: isSelected ? 14 : 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct OnboardingFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(AppTheme.softAccent)
                .frame(width: 36, height: 36)
                .background(AppTheme.softAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppTheme.hairline, lineWidth: 1)
        )
    }
}
