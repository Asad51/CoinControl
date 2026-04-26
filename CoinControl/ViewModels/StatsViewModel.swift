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
    @Published var currentDate = Date()
    @Published var startDate = Date()
    @Published var endDate = Date()

    @Published var stats: [CategoryStat] = []
    @Published var totalExpenses: Double = 0.0

    // Properties for viewing transactions of a specific category
    @Published var selectedCategory: Category? = nil
    @Published var categoryTransactions: [Transaction] = []

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
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        // Filter: Expenses only and within date range
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "type == %d", TransactionType.expense.rawValue),
            NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate),
        ])

        do {
            let transactions = try context.fetch(request)
            calculateStats(from: transactions)

            // If we are currently viewing a category's transactions, update that list too
            if let selected = selectedCategory {
                fetchTransactions(for: selected)
            }
        } catch {
            print("Fetch failed: \(error)")
        }
    }

    /// Fetches all expense transactions for a specific category within the current date range.
    func fetchTransactions(for category: Category) {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "category == %@", category),
            NSPredicate(format: "type == %d", TransactionType.expense.rawValue),
            NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate),
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        do {
            categoryTransactions = try context.fetch(request)
        } catch {
            print("Fetch category transactions failed: \(error)")
        }
    }

    private func calculateStats(from transactions: [Transaction]) {
        let grouped = Dictionary(grouping: transactions) { $0.category! }
        let total = transactions.reduce(0) { $0 + $1.amount }
        totalExpenses = total

        // Sort by amount descending to assign colors (Red for top)
        let sortedData = grouped.map { category, items -> (Category, Double) in
            let sum = items.reduce(0) { $0 + $1.amount }
            return (category, sum)
        }.sorted { $0.1 > $1.1 }

        // Color palette mimicking your images
        let palette: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .gray]

        stats = sortedData.enumerated().map { index, item in
            CategoryStat(
                category: item.0,
                amount: item.1,
                percentage: (item.1 / total) * 100,
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
