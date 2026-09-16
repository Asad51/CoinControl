//
//  InitialDataService.swift
//  CoinControl
//

import CoreData
import Foundation

class InitialDataService {
    private let container: NSPersistentContainer
    private let userDefaults: UserDefaults
    private let key = "hasInsertedInitialData"

    init(container: NSPersistentContainer = PersistenceController.shared.container, userDefaults: UserDefaults = .standard) {
        self.container = container
        self.userDefaults = userDefaults
    }

    /// Seeds the default categories and accounts on first launch.
    ///
    /// Runs synchronously so the data exists before the UI can be used; the insert is
    /// small and only happens once. Returns `true` when the data is present.
    @discardableResult
    func checkAndInsertInitialData() -> Bool {
        guard !userDefaults.bool(forKey: key) else { return true }

        let context = container.viewContext
        var succeeded = false

        context.performAndWait {
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            insertCategories(in: context)
            insertAccounts(in: context)

            do {
                try context.save()
                succeeded = true
            } catch {
                CCLogger.error("Failed to save initial data: \(error)")
                context.rollback()
            }
        }

        if succeeded {
            userDefaults.set(true, forKey: key)
            CCLogger.info("Initial data inserted successfully.")
        }

        return succeeded
    }

    private func insertCategories(in context: NSManagedObjectContext) {
        let expenseCategories = [
            ("Food", "🍜"),
            ("Social Life", "👥"),
            ("Pets", "🐶"),
            ("Transport", "🚕"),
            ("Culture", "🖼️"),
            ("Household", "🪑"),
            ("Apparel", "👕"),
            ("Beauty", "💄"),
            ("Health", "🧘"),
            ("Entertainment", "🎮"),
            ("Education", "📙"),
            ("Gift", "🎁"),
            ("Others", "✨"),
        ]

        for (name, icon) in expenseCategories {
            let category = Category(context: context)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.type = TransactionType.expense.rawValue
            category.desc = ""
        }

        let incomeCategories = [
            ("Allowance", "💵"),
            ("Salary", "💰"),
            ("Petty cash", "👛"),
            ("Bonus", "🧧"),
            ("Others", "✨"),
        ]

        for (name, icon) in incomeCategories {
            let category = Category(context: context)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.type = TransactionType.income.rawValue
            category.desc = ""
        }
    }

    private func insertAccounts(in context: NSManagedObjectContext) {
        let accounts = [
            ("Cash", AccountType.cash),
            ("Bank", AccountType.bank),
            ("Credit Card", AccountType.card),
        ]

        for (name, type) in accounts {
            let account = Account(context: context)
            account.id = UUID()
            account.name = name
            account.accountType = type.rawValue
        }
    }
}
