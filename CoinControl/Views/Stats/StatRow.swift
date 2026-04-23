//
//  StatRow.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import SwiftUI

struct StatRow: View {
    let stat: CategoryStat

    var body: some View {
        HStack(spacing: 16) {
            // Percentage Badge
            Text("\(Int(stat.percentage))%")
                .font(.caption2).bold()
                .frame(width: 35, height: 20)
                .background(stat.color)
                .foregroundColor(.white)
                .cornerRadius(4)

            Text(stat.category.icon)
                .font(.title3)

            Text(stat.category.name)
                .font(.body)

            Spacer()

            Text("৳ \(String(format: "%.2f", stat.amount))")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 12)
    }
}
