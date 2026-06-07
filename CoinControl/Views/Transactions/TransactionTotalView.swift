//
//  TransactionTotalView.swift
//  CoinControl
//

import SwiftUI

struct TransactionTotalView: View {
    @EnvironmentObject private var settings: Settings
    @ObservedObject var viewModel: TransactionsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // --- Accounts Section ---
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "tray.2.fill")
                        Text("Accounts")
                            .font(.headline)
                        Spacer()
                        Text(viewModel.selectedMonthRangeString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                        AccountSummaryRow(
                            title: "Compared to last month",
                            value: "\(Int(viewModel.expenseComparisonPercentage))% of last month",
                            trend: viewModel.expenseTrend
                        )
                        Divider().padding(.horizontal)
                        AccountSummaryRow(title: "Expenses (Cash, Accounts)", value: CurrencyFormatter.format(viewModel.monthlyExpenseCashAndBank, currencySymbol: settings.currencySymbol))
                        Divider().padding(.horizontal)
                        AccountSummaryRow(title: "Expenses (Card)", value: CurrencyFormatter.format(viewModel.monthlyExpenseCard, currencySymbol: settings.currencySymbol))
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // --- Export Button ---
                Button(action: {}) {
                    HStack {
                        Image(systemName: "tablecells")
                            .foregroundColor(.green)
                        Text("Export data to Excel")
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 80) // Space for floating button
            }
            .padding(.top)
        }
    }
}

struct AccountSummaryRow: View {
    let title: String
    let value: String
    var trend: String?

    private var trendIcon: String? {
        switch trend {
            case "increase": return "arrow.up.right"
            case "decrease": return "arrow.down.right"
            default: return nil
        }
    }

    private var trendColor: Color {
        switch trend {
            case "increase": return .red
            case "decrease": return .green
            default: return .secondary
        }
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            if let icon = trendIcon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(trendColor)
            }
            Text(value)
                .font(.subheadline)
                .fontWeight(trend == nil ? .semibold : .regular)
        }
        .padding()
    }
}

#if DEBUG
    #Preview {
        TransactionTotalView(viewModel: TransactionsViewModel())
            .preferredColorScheme(.dark)
    }
#endif
