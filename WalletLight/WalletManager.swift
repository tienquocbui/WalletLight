import SwiftUI
import Charts
import Foundation
import CoreHaptics

class WalletManager: ObservableObject {
    enum TransactionType: String, Codable { case add, remove }

    struct Transaction: Identifiable, Codable {
        let id: UUID
        let amount: Double
        let type: TransactionType
        let date: Date

        var dateFormatted: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }

    @Published var moneyDenominations: [Double: Int] = [:]
    @Published var totalBalance: Double = 0.0
    @Published var transactionHistory: [Transaction] = []
    @Published var savingsGoal: Double = UserDefaults.standard.double(forKey: "savingsGoal")

    private var hapticEngine: CHHapticEngine?

    init() {
        loadSavedDenominations()
        loadTransactions()
        prepareHaptics()
    }

    func addMoney(denomination: Double) {
        moneyDenominations[denomination, default: 0] += 1
        totalBalance += denomination
        addTransaction(amount: denomination, type: .add)
        saveDenominations()
        triggerHapticFeedback()
        UIAccessibility.post(notification: .announcement, argument: "Added \(formattedDenomination(denomination)). Total balance is now \(formattedDenomination(totalBalance)).")
    }

    func removeMoney(denomination: Double) {
        guard let count = moneyDenominations[denomination], count > 0 else { return }
        moneyDenominations[denomination] = count - 1
        totalBalance -= denomination
        if moneyDenominations[denomination] == 0 { moneyDenominations.removeValue(forKey: denomination) }
        addTransaction(amount: denomination, type: .remove)
        saveDenominations()
        triggerHapticFeedback()
        UIAccessibility.post(notification: .announcement, argument: "Removed \(formattedDenomination(denomination)). Total balance is now \(formattedDenomination(totalBalance)).")
    }

    func clearAllDenominations() {
        moneyDenominations.removeAll()
        totalBalance = 0.0
        saveDenominations()
        UIAccessibility.post(notification: .announcement, argument: "All denominations cleared. Total balance is now 0 euro.")
    }

    func setSavingsGoal(_ goal: Double) {
        savingsGoal = goal
        UserDefaults.standard.set(goal, forKey: "savingsGoal")
        UIAccessibility.post(notification: .announcement, argument: "Savings goal set to \(Int(goal)) euros.")
    }

    private func addTransaction(amount: Double, type: TransactionType) {
        let transaction = Transaction(id: UUID(), amount: amount, type: type, date: Date())
        transactionHistory.insert(transaction, at: 0)
        saveTransactions()
    }

    func clearTransactionHistory() {
        transactionHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: "transactionHistory")
        objectWillChange.send() // Refresh UI
        UIAccessibility.post(notification: .announcement, argument: "Transaction history cleared.")
    }

    func saveTransactions() {
        if let data = try? JSONEncoder().encode(transactionHistory) {
            UserDefaults.standard.set(data, forKey: "transactionHistory")
        }
    }

    func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: "transactionHistory"),
           let transactions = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactionHistory = transactions
        }
    }

    func saveDenominations() {
        if let data = try? JSONEncoder().encode(moneyDenominations) {
            UserDefaults.standard.set(data, forKey: "savedDenominations")
        }
    }

    func loadSavedDenominations() {
        if let data = UserDefaults.standard.data(forKey: "savedDenominations"),
           let savedDenominations = try? JSONDecoder().decode([Double: Int].self, from: data) {
            moneyDenominations = savedDenominations
            totalBalance = moneyDenominations.reduce(0) { $0 + $1.key * Double($1.value) }
        }
    }

    private func prepareHaptics() {
        do { hapticEngine = try CHHapticEngine() } catch { print("Failed to prepare haptics") }
    }

    func triggerHapticFeedback() {
        guard let engine = hapticEngine else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            try engine.start()
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic error: \(error.localizedDescription)")
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
        case 1.0: return "1 euro"
        case 2.0: return "2 euros"
        default: return "\(Int(amount)) euros"
        }
    }
}
