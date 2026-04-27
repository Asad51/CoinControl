//
//  CategoryDetailViewModel.swift
//  CoinControl
//
//  Created by Gemini CLI on 26/4/27.
//

import CoreData
import Foundation
import SwiftUI

@MainActor
class CategoryDetailViewModel: ObservableObject {
    let category: Category
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current

    @Published var currentDate = Date()
    @Published var transactions: [Transaction] = []
    @Published var trendData: [TrendPoint] = []
    @Published var totalAmount: Double = 0.0

    struct TrendPoint: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Double
    }

    init(category: Category, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.category = category
        self.context = context
        fetchData()
    }

    func fetchData() {
        fetchCurrentMonthTransactions()
        fetchTrendData()
    }

    func navigate(direction: Int) {
        currentDate = calendar.date(byAdding: .month, value: direction, to: currentDate) ?? currentDate
        fetchData()
    }

    private func fetchCurrentMonthTransactions() {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!.addingTimeInterval(-1)

        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "category == %@", category),
            NSPredicate(format: "type == %d", TransactionType.expense.rawValue),
            NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate),
        ])
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        do {
            transactions = try context.fetch(request)
            totalAmount = transactions.reduce(0) { $0 + $1.amount }
        } catch {
            print("Fetch current month transactions failed: \(error)")
        }
    }

    private func fetchTrendData() {
        // Fetch last 8 months including current
        var points: [TrendPoint] = []
        for i in (0 ..< 8).reversed() {
            if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
                let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!.addingTimeInterval(-1)

                let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "category == %@", category),
                    NSPredicate(format: "type == %d", TransactionType.expense.rawValue),
                    NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate),
                ])

                do {
                    let results = try context.fetch(request)
                    let sum = results.reduce(0) { $0 + $1.amount }
                    points.append(TrendPoint(date: startOfMonth, amount: sum))
                } catch {
                    print("Fetch trend data failed: \(error)")
                }
            }
        }
        trendData = points
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: currentDate)
    }

    var groupedTransactions: [(Date, [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}
