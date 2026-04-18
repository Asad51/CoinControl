//
//  DailySectionView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 18/4/26.
//

import SwiftUI

struct DailySectionView: View {
    let date: Date
    let items: [Transaction]
    let onRowTapped: (Transaction) -> Void

    var dailyExpense: Double {
        items.filter(\.isExpense).reduce(0) { $0 + $1.amount }
    }

    var dailyIncome: Double {
        items.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Date Header
            HStack {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(dateFormatter(date, format: "dd"))
                        .font(.title2).bold()
                        .foregroundColor(.primary)
                    Text(dateFormatter(date, format: "EEE MM.yyyy"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(4)
                }

                Spacer()

                HStack(spacing: 16) {
                    Text("৳ \(String(format: "%.2f", dailyIncome))")
                        .foregroundColor(.blue)
                    Text("৳ \(String(format: "%.2f", dailyExpense))")
                        .foregroundColor(.red)
                }
                .font(.system(.subheadline, design: .monospaced))
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))

            // Items list
            ForEach(items) { item in
                Button(action: {
                    onRowTapped(item)
                }) {
                    TransactionRowView(item: item)
                }
                .buttonStyle(PlainButtonStyle()) // Removes default button flash/tint
            }

            Divider()
        }
    }

    func dateFormatter(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(\.transactions) { transactions in
            DailySectionView(date: Date().addingTimeInterval(-100_000), items: transactions) { _ in
            }
        }
    }
#endif
