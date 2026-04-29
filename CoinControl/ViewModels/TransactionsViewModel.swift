//
//  TransactionsViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class TransactionsViewModel: NSObject, ObservableObject {
    @Published var groupedTransactions: [(Date, [Transaction])] = []
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

    var selectedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: selectedDate)
    }

    private func updateGroupedTransactions() {
        let allTransactions = fetchedResultsController.fetchedObjects ?? []

        let calendar = Calendar.current
        let transactions = allTransactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .month)
        }

        totalIncome = transactions
            .filter { $0.type == TransactionType.income.rawValue }
            .reduce(0) { $0 + $1.amount }

        totalExpenses = transactions
            .filter { $0.type == TransactionType.expense.rawValue }
            .reduce(0) { $0 + $1.amount }

        totalBalance = totalIncome - totalExpenses

        let grouped = Dictionary(grouping: transactions) { item in
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
