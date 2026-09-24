import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("userName") var name: String = ""
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
}
