import SwiftUI

struct MainView: View {
    @StateObject var navigationManager = NavigationManager()
    
    var body: some View {
        ZStack {
            switch navigationManager.currentView {
            case .home:
                HomeView()
            case .wallet:
                WalletView()
            case .calculate:
                CalculateView()
            }
            
            VStack {
                Spacer()
                CustomNavBar()
                    .environmentObject(navigationManager)
                
            }
        }
        .environmentObject(navigationManager)
    }
}
