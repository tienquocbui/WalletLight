import SwiftUI

struct SavingsGoalView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.presentationMode) var presentationMode
    @State private var goalAmount: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set Savings Goal")
                .font(.title2).bold()
            
            HStack {
                Text("Goal: ")
                TextField("Amount in €", value: $goalAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            Button("Save Goal") {
                walletManager.setSavingsGoal(goalAmount)
                walletManager.triggerHapticFeedback()
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear { goalAmount = walletManager.savingsGoal }
    }
}
