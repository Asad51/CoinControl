//
//  TransactionRowView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 18/4/26.
//

import SwiftUI

struct TransactionRowView: View {
    @ObservedObject var item: Transaction

    var body: some View {
        HStack(spacing: 16) {
            // Icon Stack
            HStack(spacing: 8) {
                Text(item.category?.icon ?? "💰")
                    .font(.title3)
                    .frame(width: 32, height: 32)

                Text(item.category?.name ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                    .lineLimit(1)
            }

            // Title & Account
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(item.account?.name ?? "Cash")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Amount
            Text("৳ \(String(format: "%.2f", item.amount))")
                .foregroundColor(item.type == TransactionType.expense.rawValue ? Color.red : .blue)
                .font(.system(.subheadline, design: .monospaced))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(item: \.transaction) { transaction in
            TransactionRowView(item: transaction)
        }
    }
#endif
