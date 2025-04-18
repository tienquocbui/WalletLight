import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Transaction History")
                .font(.title2)
                .bold()
                .padding(.top)
                .accessibilityLabel("Transaction History Heading")

            if walletManager.transactionHistory.isEmpty {
                Text("No transactions yet.")
                    .foregroundColor(.gray)
                    .accessibilityLabel("No transactions available")
            } else {
                List(walletManager.transactionHistory) { transaction in
                    HStack {
                        Text(transaction.type == .add ? "Added" : "Removed")
                            .bold()
                            .foregroundColor(transaction.type == .add ? .green : .red)
                            .accessibilityLabel(transaction.type == .add ? "Money Added" : "Money Removed")

                        Text(walletManager.formattedDenomination(transaction.amount))
                            .accessibilityLabel("Amount: \(walletManager.formattedDenomination(transaction.amount))")

                        Spacer()

                        Text(transaction.dateFormatted)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .accessibilityLabel("Date: \(transaction.dateFormatted)")
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityHint("Double tap for details")
                }
                .cornerRadius(10)
            }

            Button(action: { showAlert = true }) {
                Label("Clear History", systemImage: "trash")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .accessibilityLabel("Clear Transaction History")
                    .accessibilityHint("Double tap to clear all transactions")
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Confirm Clear History"),
                    message: Text("Are you sure you want to clear all transaction history?"),
                    primaryButton: .destructive(Text("Clear")) {
                        walletManager.clearTransactionHistory()
                    },
                    secondaryButton: .cancel()
                )
            }

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Label("Back", systemImage: "arrow.backward")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .accessibilityLabel("Go Back")
                    .accessibilityHint("Double tap to return to the previous screen")
            }
            .padding(.bottom)
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
}
