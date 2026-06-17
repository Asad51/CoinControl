//
//  AppColors.swift
//  CoinControl
//

import SwiftUI

enum AppColors {
    // Semantic Colors
    static let income = Color.green
    static let expense = Color.red
    static let total = Color.primary

    // Accent color is managed via Settings.accentColor
}

extension Color {
    static let appIncome = AppColors.income
    static let appExpense = AppColors.expense
    static let appTotal = AppColors.total
}
