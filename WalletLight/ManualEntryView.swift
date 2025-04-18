import SwiftUI

struct ManualEntryView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.presentationMode) var presentationMode

    let validDenominations: [Double] = [
        0.01, 0.02, 0.05, 0.10, 0.20, 0.50, // cent coins
        1.0, 2.0,                           // euro coins
        5.0, 10.0, 20.0, 50.0, 100.0, 200.0 // euro bills
    ]

    @State private var selectedAmount: Double = 5.0

    var body: some View {
        VStack {
            Text("Enter Money Amount")
                .font(.headline)
                .padding()

            // Display total balance with precise decimal formatting
            Text("Total Balance: \(formattedAmount(walletManager.totalBalance))")
                .font(.title2)
                .padding(.bottom, 10)

            Picker("Select Amount", selection: $selectedAmount) {
                ForEach(validDenominations, id: \.self) { amount in
                    Text(formattedDenomination(amount)).tag(amount)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()

            HStack {
                Spacer()
                Button(action: {
                    walletManager.addMoney(denomination: selectedAmount)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                Spacer()
            }
            .padding()
        }
        .padding()
    }

    func formattedDenomination(_ amount: Double) -> String {
        switch amount {
        case 0.01: return "1 cent"
        case 0.02: return "2 cents"
        case 0.05: return "5 cents"
        case 0.10: return "10 cents"
        case 0.20: return "20 cents"
        case 0.50: return "50 cents"
        case 1.0:  return "1 euro"
        case 2.0:  return "2 euros"
        default:    return "\(Int(amount)) euros"
        }
    }

    func formattedAmount(_ amount: Double) -> String {
        if amount < 1.0 {
            let cents = Int(round(amount * 100))
            return cents == 1 ? "1 cent" : "\(cents) cents"
        } else if amount == 1.0 {
            return "1 euro"
        } else {
            // Show two decimal places for amounts with cents (e.g., 415.15 euros)
            return amount.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(amount)) euros" : String(format: "%.2f euros", amount)
        }
    }
}
