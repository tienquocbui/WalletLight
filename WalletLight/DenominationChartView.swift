import SwiftUI
import Charts

struct DenominationChartView: View {
    @EnvironmentObject var walletManager: WalletManager
    @Environment(\.presentationMode) var presentationMode

    var sortedDenominations: [(key: Double, value: Int)] {
        walletManager.moneyDenominations.sorted(by: { $0.key < $1.key })
    }

    var totalDenominationCount: Int {
        walletManager.moneyDenominations.values.reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Denomination Breakdown")
                .font(.title2)
                .bold()
                .padding(.top)
                .multilineTextAlignment(.center)

            if walletManager.moneyDenominations.isEmpty {
                Text("No data to display.")
                    .foregroundColor(.gray)
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        Chart {
                            ForEach(sortedDenominations, id: \.key) { denomination, count in
                                let percentage = totalDenominationCount > 0 ? (Double(count) / Double(totalDenominationCount)) * 100 : 0

                                SectorMark(
                                    angle: .value("Percentage", percentage),
                                    innerRadius: .ratio(0.5),
                                    outerRadius: .ratio(1.0)
                                )
                                .foregroundStyle(color(for: denomination))
                                .accessibilityLabel("\(formattedDenomination(denomination)): \(String(format: "%.2f", percentage)) percent")
                            }
                        }
                        .frame(width: min(geometry.size.width, geometry.size.height) * 0.4,
                               height: min(geometry.size.width, geometry.size.height) * 0.4)

                        Divider()

                        Text("Legend")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(sortedDenominations, id: \.key) { denomination, count in
                                let percentage = totalDenominationCount > 0 ? (Double(count) / Double(totalDenominationCount)) * 100 : 0

                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(color(for: denomination))
                                        .frame(width: 14, height: 14)

                                    Text("\(formattedDenomination(denomination)): \(String(format: "%.2f", percentage))%")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(6)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(height: 420)
            }

            Spacer()

            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Label("Back", systemImage: "arrow.backward")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .padding()
    }

    func color(for denomination: Double) -> Color {
        switch denomination {
        case 0.01: return Color.gray.opacity(0.2)
        case 0.02: return Color.gray.opacity(0.3)
        case 0.05: return Color.gray.opacity(0.4)
        case 0.10: return Color.gray.opacity(0.5)
        case 0.20: return Color.gray.opacity(0.6)
        case 0.50: return Color.gray.opacity(0.7)
        case 1.0: return .red
        case 2.0: return .orange
        case 5.0: return .yellow
        case 10.0: return .green
        case 20.0: return .blue
        case 50.0: return .purple
        case 100.0: return .pink
        case 200.0: return .teal
        default: return .black
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
