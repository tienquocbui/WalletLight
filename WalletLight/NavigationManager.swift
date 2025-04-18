import SwiftUI

class NavigationManager: ObservableObject {
    enum AppView: String, CaseIterable {
        case home, wallet, calculate
    }

    @Published var currentView: AppView = .home
}
