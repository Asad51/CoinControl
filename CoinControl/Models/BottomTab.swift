//
//  BottomTab.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 14/2/24.
//

import Foundation

enum BottomTab: String, CaseIterable {
    case transactions
    case stats
    case accounts

    var title: String {
        switch self {
            case .transactions:
                "Trans."
            case .stats:
                "Stats"
            case .accounts:
                "Accounts"
        }
    }

    var systemImage: String {
        switch self {
            case .transactions:
                "book.pages"
            case .stats:
                "chart.bar.xaxis"
            case .accounts:
                "dollarsign.bank.building.fill"
        }
    }
}
