//
//  PreviewData.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 15/2/24.
//

import CoreData
import Foundation

struct PreviewData {
    var record: (NSManagedObjectContext) -> Record {{ context in
        let category = Category(context: context)
        category.name = "Groceries"
        category.slug = "groceries"

        let record = Record(context: context)
        record.date = Date().addingTimeInterval(-100_000)
        record.category = category
        record.account = "Cash"
        record.amount = -10.61
        record.note = "Chicken"
        record.recordDescription = "Bought 6kgs of chicken."

        return record
    }}

    var records: (NSManagedObjectContext) -> [Record] {{ context in
        let category1 = Category(context: context)
        category1.name = "Groceries"
        category1.slug = "groceries"

        let category2 = Category(context: context)
        category2.name = "Salary"
        category2.slug = "salary"

        let record1 = Record(context: context)
        record1.date = Date().addingTimeInterval(-100_000)
        record1.category = category1
        record1.account = "Accounts"
        record1.amount = -12.0
        record1.note = "Tea"
        record1.recordDescription = "Consumed tea with Mr. Maruf."

        let record2 = Record(context: context)
        record2.date = Date().addingTimeInterval(-1_000_000)
        record2.category = category2
        record2.account = "Accounts"
        record2.amount = 14444.0
        record2.note = "Salary"
        record2.recordDescription = "Salary + Bonus"

        return [record1, record2]
    }}
}
