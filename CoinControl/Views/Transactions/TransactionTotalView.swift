//
//  TransactionTotalView.swift
//  CoinControl
//

import SwiftUI

struct TransactionTotalView: View {
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
                        AccountSummaryRow(title: "Compared Expenses (Last month)", value: "\(Int(viewModel.expenseComparisonPercentage))%", isPercentage: true)
                        Divider().padding(.horizontal)
                        AccountSummaryRow(title: "Expenses (Cash, Accounts)", value: "৳ \(String(format: "%.2f", viewModel.monthlyExpenseCashAndBank))")
                        Divider().padding(.horizontal)
                        AccountSummaryRow(title: "Expenses (Card)", value: "৳ \(String(format: "%.2f", viewModel.monthlyExpenseCard))")
                        Divider().padding(.horizontal)
                        AccountSummaryRow(title: "Transfer (Cash, Accounts -> )", value: "৳ \(String(format: "%.2f", viewModel.monthlyTransfer))")
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
    var isPercentage: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(isPercentage ? .regular : .semibold)
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
