//
//  DailySectionView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 18/4/26.
//

import SwiftUI

struct DailySectionView: View {
    private let viewModel: DailySectionViewModel
    let onRowTapped: (Transaction) -> Void

    init(date: Date, items: [Transaction], onRowTapped: @escaping (Transaction) -> Void) {
        viewModel = DailySectionViewModel(date: date, items: items)
        self.onRowTapped = onRowTapped
    }

    var body: some View {
        VStack(spacing: 0) {
            // Date Header
            HStack {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(viewModel.formattedDate(format: "dd"))
                        .font(.title2).bold()
                        .foregroundColor(.primary)
                    Text(viewModel.formattedDate(format: "EEE MM.yyyy"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(4)
                }

                Spacer()

                HStack(spacing: 16) {
                    Text("৳ \(String(format: "%.2f", viewModel.dailyIncome))")
                        .foregroundColor(.blue)
                    Text("৳ \(String(format: "%.2f", viewModel.dailyExpense))")
                        .foregroundColor(.red)
                }
                .font(.system(.subheadline, design: .monospaced))
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))

            // Items list
            ForEach(viewModel.items) { item in
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
}

#if DEBUG
    #Preview {
        CoreDataPreview(items: \.transactions) { transactions in
            DailySectionView(date: Date().addingTimeInterval(-100_000), items: transactions) { _ in
            }
        }
    }
#endif
