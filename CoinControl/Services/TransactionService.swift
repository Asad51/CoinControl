//
//  TransactionService.swift
//  CoinControl
//

import CoreData
import Foundation

protocol TransactionServiceProtocol {
    func getTransactionsFRC() -> NSFetchedResultsController<Transaction>
    func saveTransaction(id: UUID?, type: Int16, amount: Double, date: Date, title: String, note: String, category: Category?, account: Account?) throws
    func deleteTransaction(_ transaction: Transaction) throws
}

class TransactionService: TransactionServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func getTransactionsFRC() -> NSFetchedResultsController<Transaction> {
        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]

        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    func saveTransaction(id: UUID?, type: Int16, amount: Double, date: Date, title: String, note: String, category: Category?, account: Account?) throws {
        let transaction: Transaction

        if let id {
            let request = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let existing = try context.fetch(request).first {
                transaction = existing
            } else {
                transaction = Transaction(context: context)
                transaction.id = id
            }
        } else {
            transaction = Transaction(context: context)
            transaction.id = UUID()
        }

        transaction.type = type
        transaction.amount = amount
        transaction.date = date
        transaction.note = note
        transaction.title = title
        transaction.category = category
        transaction.account = account

        try context.save()
    }

    func deleteTransaction(_ transaction: Transaction) throws {
        context.delete(transaction)
        try context.save()
    }
}
