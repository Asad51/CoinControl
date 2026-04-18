//
//  PreviewData.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 15/2/24.
//

import CoreData
import Foundation

struct PreviewData {
    var transaction: (NSManagedObjectContext) -> Transaction {{ context in
        let category = Category(context: context)
        category.id = UUID()
        category.name = "Groceries"
        category.icon = "cart"
        category.desc = "groceries"

        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.title = "Chicken"
        transaction.date = Date().addingTimeInterval(-100_000)
        transaction.category = category
        transaction.account = "Cash"
        transaction.amount = 10.61
        transaction.isExpense = true
        transaction.note = "Bought 6kgs of chicken."

        return transaction
    }}

    var transactions: (NSManagedObjectContext) -> [Transaction] {{ context in
        let category1 = Category(context: context)
        category1.id = UUID()
        category1.name = "Groceries"
        category1.icon = "cart"
        category1.desc = "groceries"

        let category2 = Category(context: context)
        category2.id = UUID()
        category2.name = "Salary"
        category2.icon = "briefcase"
        category2.desc = "salary"

        let transaction1 = Transaction(context: context)
        transaction1.id = UUID()
        transaction1.title = "Tea"
        transaction1.date = Date().addingTimeInterval(-100_000)
        transaction1.category = category1
        transaction1.account = "Accounts"
        transaction1.amount = 12.0
        transaction1.isExpense = true
        transaction1.note = "Consumed tea with Mr. Maruf."

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.title = "Salary"
        transaction2.date = Date().addingTimeInterval(-1_000_000)
        transaction2.category = category2
        transaction2.account = "Accounts"
        transaction2.amount = 14444.0
        transaction1.isExpense = false
        transaction2.note = "Salary + Bonus"

        let transaction3 = Transaction(context: context)
        transaction3.id = UUID()
        transaction3.title = "Snacks"
        transaction3.date = Date().addingTimeInterval(-100_000)
        transaction3.category = category1
        transaction3.account = "Accounts"
        transaction3.amount = 20.0
        transaction3.isExpense = true
        transaction3.note = "Consumed tea with Mr. Maruf."

        return [transaction1, transaction2, transaction3]
    }}
}
