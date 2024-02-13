//
//  BottomTab.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 14/2/24.
//

import Foundation

enum BottomTab: String, CaseIterable {
    case records
    case stats
    case accounts

    var title: String {
        switch self {
            case .records:
                "Records"
            case .stats:
                "Stats"
            case .accounts:
                "Accounts"
        }
    }

    var systemImage: String {
        switch self {
            case .records:
                "text.book.closed"
            case .stats:
                "list.bullet.rectangle"
            case .accounts:
                "dollarsign.circle"
        }
    }
}
