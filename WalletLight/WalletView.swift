import SwiftUI
import Charts

struct WalletView: View {
    @EnvironmentObject var walletManager: WalletManager
    @State private var showAddMoneyOptions = false
    @State private var showManualEntry = false
    @State private var showScanMoney = false
    @State private var showChart = false
    @State private var showHistory = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllConfirmation = false
    @State private var denominationToDelete: Double?
    @State private var showSavingsGoal = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("Wallet")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 6)

                Text("Total Balance: \(formattedAmount(walletManager.totalBalance))")
                    .font(.title2)
                    .padding(.bottom, 2)
            }
            .padding(.top, 10)

            Divider()

            // Savings Goal Section
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Savings Goal: \(formattedAmount(walletManager.savingsGoal))")
                        .font(.headline)

                    if walletManager.totalBalance >= walletManager.savingsGoal && walletManager.savingsGoal > 0 {
                        Text("🎉 Goal Achieved!")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.leading, 18)
                    }

                    Spacer()

                    Button(action: { showSavingsGoal = true }) {
                        Image(systemName: "square.and.pencil")
                            .bold()
                            .foregroundColor(.blue)
                            .padding(5)
                    }
                    .accessibilityLabel("Edit savings goal")
                }

                ProgressView(value: min(walletManager.totalBalance / max(walletManager.savingsGoal, 1), 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 1.5)
                    .accessibilityLabel("Progress towards savings goal")
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)

            // Buttons Section
            HStack(spacing: 12) {
                Button(action: { showChart = true }) {
                    Label("Money Breakdown", systemImage: "chart.pie.fill")
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showChart) {
                    DenominationChartView().environmentObject(walletManager)
                }

                Button(action: { showHistory = true }) {
                    Label("Transaction History", systemImage: "clock.fill")
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showHistory) {
                    TransactionHistoryView().environmentObject(walletManager)
                }
            }

            Divider()

            // Denominations Section with Delete All Button
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Denominations")
                        .font(.headline)

                    Spacer()

                    Button(action: { showDeleteAllConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                    }
                    .accessibilityLabel("Delete all denominations")
                    .alert(isPresented: $showDeleteAllConfirmation) {
                        Alert(
                            title: Text("Confirm Deletion"),
                            message: Text("Are you sure you want to delete all denominations and reset total balance?"),
                            primaryButton: .destructive(Text("Delete All")) {
                                walletManager.clearAllDenominations()
                                walletManager.triggerHapticFeedback()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }

                List {
                    ForEach(walletManager.moneyDenominations.sorted(by: { $0.key < $1.key }), id: \.key) { denomination, count in
                        HStack {
                            Text("\(formattedDenomination(denomination)) x \(count)")
                                .font(.headline)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    denominationToDelete = denomination
                                    showDeleteConfirmation = true
                                }

                            Spacer()

                            Button(action: {
                                denominationToDelete = denomination
                                showDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .frame(height: 310)
                .listStyle(InsetGroupedListStyle())
                .cornerRadius(10)
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to remove \(formattedDenomination(denominationToDelete ?? 0))?"),
                        primaryButton: .destructive(Text("Remove")) {
                            if let denomination = denominationToDelete {
                                walletManager.removeMoney(denomination: denomination)
                                walletManager.triggerHapticFeedback()
                                walletManager.saveDenominations()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }

            // Add Money Button
            Button(action: {
                showAddMoneyOptions = true
                walletManager.triggerHapticFeedback()
            }) {
                Text("Add Money")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.vertical, 1)
            .actionSheet(isPresented: $showAddMoneyOptions) {
                ActionSheet(title: Text("Add Money"), buttons: [
                    .default(Text("Enter Manually")) { showManualEntry = true },
                    .default(Text("Scan Money")) { showScanMoney = true },
                    .cancel()
                ])
            }

            Spacer(minLength: 20)
        }
        .padding([.horizontal, .top], 4)
        .padding(.bottom, 10)
        .onAppear {
            walletManager.loadSavedDenominations()
        }
        .sheet(isPresented: $showManualEntry) {
            ManualEntryView().environmentObject(walletManager)
        }
        .sheet(isPresented: $showScanMoney) {
            ScanMoneyView().environmentObject(walletManager)
        }
        .sheet(isPresented: $showSavingsGoal) {
            SavingsGoalView().environmentObject(walletManager)
        }
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
        if amount == 0 {
            return "0 euro"
        } else if amount == 1.0 {
            return "1 euro"
        } else if amount < 1.0 {
            let cents = Int(round(amount * 100))
            return cents == 1 ? "1 cent" : "\(cents) cents"
        } else if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(amount)) euros"
        } else {
            return String(format: "%.2f euros", amount)
        }
    }
}
