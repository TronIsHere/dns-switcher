import SwiftUI

struct RootView: View {
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Group {
            if settings.hasCompletedOnboarding {
                ContentView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: settings.hasCompletedOnboarding)
    }
}
