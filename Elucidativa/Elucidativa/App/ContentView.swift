import SwiftUI

struct ContentView: View {
    @StateObject private var userSettings = UserSettings()
    @StateObject private var homeViewModel = HomeViewModel() // The viewModel needs to be created here

    var body: some View {
        if userSettings.hasCompletedOnboarding {
            MainView()
                .environmentObject(userSettings)
                .environmentObject(homeViewModel)
        } else {
            OnboardingView()
                .environmentObject(userSettings)
        }
    }
}
