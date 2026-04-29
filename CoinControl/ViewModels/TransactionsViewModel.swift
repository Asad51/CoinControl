//
//  TransactionsViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class TransactionsViewModel: NSObject, ObservableObject {
    @Published var groupedTransactions: [(Date, [Transaction])] = []
    @Published var yearlyTransactions: [(Date, [Transaction])] = []
    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var totalBalance: Double = 0
    @Published var selectedDate: Date = .init()

    private let fetchedResultsController: NSFetchedResultsController<Transaction>
    private let transactionService: TransactionServiceProtocol

    init(transactionService: TransactionServiceProtocol = TransactionService()) {
        self.transactionService = transactionService
        fetchedResultsController = transactionService.getTransactionsFRC()

        super.init()
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            updateGroupedTransactions()
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    func nextYear() {
        if let newDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    func previousYear() {
        if let newDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    var selectedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: selectedDate)
    }

    var selectedYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedDate)
    }

    func updateGroupedTransactions() {
        let allTransactions = fetchedResultsController.fetchedObjects ?? []
        let calendar = Calendar.current

        // 1. Update Yearly Grouping
        let currentYearTransactions = allTransactions.filter {
            calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .year)
        }
        let yearlyGrouped = Dictionary(grouping: currentYearTransactions) { item in
            calendar.date(from: calendar.dateComponents([.year, .month], from: item.date))!
        }
        yearlyTransactions = yearlyGrouped.sorted { $0.key > $1.key }

        // 2. Update Monthly Grouping (for Daily/Calendar)
        let monthlyTransactions = allTransactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .month)
        }

        // 3. Update Summary Totals (Defaults to selected year if we want, but Monthly view shows yearly totals in header)
        // According to the image, the header shows yearly totals when in Monthly tab.
        // We'll calculate totals based on the year to match the header in Monthly.jpg
        totalIncome = currentYearTransactions
            .filter { $0.type == TransactionType.income.rawValue }
            .reduce(0) { $0 + $1.amount }

        totalExpenses = currentYearTransactions
            .filter { $0.type == TransactionType.expense.rawValue }
            .reduce(0) { $0 + $1.amount }

        totalBalance = totalIncome - totalExpenses

        let grouped = Dictionary(grouping: monthlyTransactions) { item in
            calendar.startOfDay(for: item.date)
        }
        groupedTransactions = grouped.sorted { $0.key > $1.key }
    }
}

extension TransactionsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        updateGroupedTransactions()
    }
}
