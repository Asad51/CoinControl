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

    func checkAndInsertInitialData() {
        guard !userDefaults.bool(forKey: key) else { return }

        container.performBackgroundTask { [weak self] backgroundContext in
            guard let self = self else { return }
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            self.insertCategories(in: backgroundContext)
            self.insertAccounts(in: backgroundContext)

            do {
                try backgroundContext.save()
                self.userDefaults.set(true, forKey: self.key)
                print("Initial data inserted successfully on background thread.")
            } catch {
                print("Failed to save initial data: \(error)")
            }
        }
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
