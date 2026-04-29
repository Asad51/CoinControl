//
//  StatsViewModel.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import CoreData
import Foundation
import SwiftUI

@MainActor
class StatsViewModel: ObservableObject {
    @Published var selectedPeriod: StatsPeriod = .monthly
    @Published var selectedType: TransactionType = .expense
    @Published var currentDate = Date()
    @Published var startDate = Date()
    @Published var endDate = Date()

    @Published var stats: [CategoryStat] = []
    @Published var totalExpenses: Double = 0.0
    @Published var totalIncome: Double = 0.0

    private let context: NSManagedObjectContext
    private let calendar = Calendar.current

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        updateDateRange()
    }

    func updateDateRange() {
        switch selectedPeriod {
            case .weekly:
                startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
                endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
            case .monthly:
                startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
                endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!.addingTimeInterval(-1)
            case .annually:
                startDate = calendar.date(from: calendar.dateComponents([.year], from: currentDate))!
                endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!.addingTimeInterval(-1)
            case .period:
                // For custom period, default to current month or a specific range
                break
        }
        fetchStats()
    }

    func navigate(direction: Int) {
        let component: Calendar.Component
        switch selectedPeriod {
            case .weekly: component = .weekOfYear
            case .monthly: component = .month
            case .annually: component = .year
            case .period: component = .month
        }
        currentDate = calendar.date(byAdding: component, value: direction, to: currentDate) ?? currentDate
        updateDateRange()
    }

    func fetchStats() {
        // Fetch all transactions in range to get both totals
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)

        do {
            let allTransactions = try context.fetch(request)

            totalIncome = allTransactions.filter { $0.type == TransactionType.income.rawValue }.reduce(0) { $0 + $1.amount }
            totalExpenses = allTransactions.filter { $0.type == TransactionType.expense.rawValue }.reduce(0) { $0 + $1.amount }

            let filteredTransactions = allTransactions.filter { $0.type == selectedType.rawValue }
            calculateStats(from: filteredTransactions)
        } catch {
            print("Fetch failed: \(error)")
        }
    }

    private func calculateStats(from transactions: [Transaction]) {
        let grouped = Dictionary(grouping: transactions) { $0.category! }
        let total = transactions.reduce(0) { $0 + $1.amount }

        // Sort by amount descending
        let sortedData = grouped.map { category, items -> (Category, Double) in
            let sum = items.reduce(0) { $0 + $1.amount }
            return (category, sum)
        }.sorted { $0.1 > $1.1 }

        // Color palette based on type
        let palette: [Color]
        if selectedType == .income {
            palette = [.blue, .cyan, .teal, .indigo, .mint, .green, .gray]
        } else {
            palette = [.red, .orange, .yellow, .pink, .purple, .brown, .gray]
        }

        stats = sortedData.enumerated().map { index, item in
            CategoryStat(
                category: item.0,
                amount: item.1,
                percentage: total > 0 ? (item.1 / total) * 100 : 0,
                color: index < palette.count ? palette[index] : .gray
            )
        }
    }

    var dateRangeString: String {
        let formatter = DateFormatter()
        switch selectedPeriod {
            case .weekly,
                 .period:
                formatter.dateFormat = "MM.dd"
                return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
            case .monthly:
                formatter.dateFormat = "MMM yyyy"
                return formatter.string(from: startDate)
            case .annually:
                formatter.dateFormat = "yyyy"
                return formatter.string(from: startDate)
        }
    }
}
