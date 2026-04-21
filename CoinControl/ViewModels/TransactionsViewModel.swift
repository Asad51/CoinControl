//
//  TransactionsViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class TransactionsViewModel: NSObject, ObservableObject {
    @Published var groupedTransactions: [(Date, [Transaction])] = []

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

    private func updateGroupedTransactions() {
        let transactions = fetchedResultsController.fetchedObjects ?? []
        let grouped = Dictionary(grouping: transactions) { item in
            Calendar.current.startOfDay(for: item.date)
        }
        groupedTransactions = grouped.sorted { $0.key > $1.key }
    }
}

extension TransactionsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        updateGroupedTransactions()
    }
}
