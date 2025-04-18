import SwiftUI

struct CustomNavBar: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        HStack {
            Spacer(minLength: 5)

            Button(action: {
                withAnimation {
                    navigationManager.currentView = .wallet
                }
            }) {
                VStack {
                    Image(systemName: "wallet.pass")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Wallet")
                        .font(.caption)
                }
            }
            .foregroundColor(navigationManager.currentView == .wallet ? .red : .white)

            Spacer(minLength: 40)

            Button(action: {
                withAnimation {
                    navigationManager.currentView = .home
                }
            }) {
                VStack {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Home")
                        .font(.caption)
                }
            }
            .foregroundColor(navigationManager.currentView == .home ? .red : .white)

            Spacer(minLength: 40)

            Button(action: {
                withAnimation {
                    navigationManager.currentView = .calculate
                }
            }) {
                VStack {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Calculate")
                        .font(.caption)
                }
            }
            .foregroundColor(navigationManager.currentView == .calculate ? .red : .white)

            Spacer(minLength: 5)
        }
        .frame(width: 320, height: 65)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .padding(.horizontal, 20)
        .padding(.bottom, -9)
    }
}

