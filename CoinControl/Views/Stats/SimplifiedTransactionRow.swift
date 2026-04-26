//
//  SimplifiedTransactionRow.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import SwiftUI

/// A simplified version of the transaction row, focused on date and amount,
/// used in the statistics detail view.
struct SimplifiedTransactionRow: View {
    @ObservedObject var transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.body)

                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("৳ \(String(format: "%.2f", transaction.amount))")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.red) // All stats transactions are expenses

                Text(transaction.account?.name ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }
}
