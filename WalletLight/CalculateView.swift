import SwiftUI
import AVFoundation

struct CalculateView: View {
    enum UserRole: String, CaseIterable, Identifiable {
        case buyer = "Buyer"
        case seller = "Seller"
        var id: String { rawValue }
    }

    @State private var selectedRole: UserRole = .buyer
    @State private var itemPrice: String = ""
    @State private var paymentAmount: Double = 0.0
    @State private var showCamera = false
    @State private var changeAmount: Double? = nil
    @FocusState private var isPriceFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Currency Calculator")
                .font(.title)
                .bold()

            Picker("Select Role", selection: $selectedRole) {
                ForEach(UserRole.allCases) { role in
                    Text(role.rawValue).tag(role)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            VStack(alignment: .leading) {
                Text("Item Price (€)")
                    .font(.headline)
                HStack {
                    TextField("Enter price", text: $itemPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isPriceFieldFocused)

                    if isPriceFieldFocused {
                        Button("Done") {
                            isPriceFieldFocused = false
                        }
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(selectedRole == .buyer ? "Payment Amount:" : "Amount Received:")
                        .font(.headline)
                    Spacer()
                    Text("€\(formatAmount(paymentAmount))")
                        .bold()
                }

                Button(action: {
                    isPriceFieldFocused = false
                    showCamera = true
                }) {
                    Label(selectedRole == .buyer ? "Scan Payment" : "Scan Received Money", systemImage: "camera.viewfinder")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()

            Button(action: calculateChange) {
                Label("Calculate Change", systemImage: "equal")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(itemPrice.isEmpty || paymentAmount == 0.0)
            .padding(.horizontal)

            if let change = changeAmount {
                VStack(spacing: 12) {
                    Text(changeResultText(for: change))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()

                    if change > 0 {
                        Text("Suggested Change: \(suggestChange(for: change))")
                            .font(.subheadline)
                            .padding()
                    }

                    Button(action: resetCalculation) {
                        Label("Reset", systemImage: "arrow.uturn.backward")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showCamera) {
            ScanMoneyView { amount in
                paymentAmount += amount // ✅ Add scanned amount on Add press
                UIAccessibility.post(notification: .announcement, argument: "Added €\(formatAmount(amount)). Total: €\(formatAmount(paymentAmount))")
            }
        }
    }

    private func formatAmount(_ amount: Double) -> String {
        String(format: amount.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2f", amount)
    }

    private func calculateChange() {
        let cleanedPrice = itemPrice.replacingOccurrences(of: ",", with: ".")
        guard let price = Double(cleanedPrice) else { return }
        changeAmount = paymentAmount - price
        UIAccessibility.post(notification: .announcement, argument: changeResultText(for: changeAmount ?? 0))
    }

    private func changeResultText(for change: Double) -> String {
        if change == 0 {
            return selectedRole == .buyer ? "Exact payment. No change needed." : "Customer paid the exact amount. No change required."
        } else if change < 0 {
            return "Additional €\(formatAmount(abs(change))) needed to complete the payment."
        } else {
            return "Change required: €\(formatAmount(change))"
        }
    }

    private func resetCalculation() {
        itemPrice = ""
        paymentAmount = 0.0
        changeAmount = nil
    }

    private func suggestChange(for amount: Double) -> String {
        let denominations: [Double] = [200, 100, 50, 20, 10, 5, 2, 1, 0.50, 0.20, 0.10, 0.05, 0.02, 0.01]
        var remaining = amount
        var suggestions: [String] = []

        for denom in denominations where remaining >= denom {
            let count = Int(remaining / denom)
            let label = denom >= 1.0 ? "\(count) x €\(Int(denom))" : "\(count) x \(Int(denom * 100)) cent\(count > 1 ? "s" : "")"
            suggestions.append(label)
            remaining -= denom * Double(count)
            remaining = Double(round(100 * remaining) / 100)
        }

        return suggestions.isEmpty ? "No suitable change available." : suggestions.joined(separator: ", ")
    }
}
