import SwiftUI

@main
struct WalletLightApp: App {
    @StateObject var navigationManager = NavigationManager()
    @StateObject var walletManager = WalletManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(navigationManager)
                .environmentObject(walletManager)
        }
    }
}
