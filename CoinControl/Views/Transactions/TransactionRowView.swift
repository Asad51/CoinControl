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
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 32, height: 32)

                    Image(systemName: item.category.icon)
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                }

                Text(item.category.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)
                    .lineLimit(1)
            }

            // Title & Account
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(item.account)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Amount
            Text("৳ \(String(format: "%.2f", item.amount))")
                .foregroundColor(item.isExpense ? .red : .blue)
                .font(.system(.subheadline, design: .monospaced))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(\.transactions) { transactions in
            TransactionRowView(item: transactions[0])
        }
    }
#endif
