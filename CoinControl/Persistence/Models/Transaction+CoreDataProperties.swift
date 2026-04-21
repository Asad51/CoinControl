//
//  Transaction+CoreDataProperties.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 19/4/26.
//
//

import CoreData
import Foundation

public typealias TransactionCoreDataPropertiesSet = NSSet

extension Transaction {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Transaction> {
        NSFetchRequest<Transaction>(entityName: "TransactionEntity")
    }

    @NSManaged var amount: Double
    @NSManaged var date: Date
    @NSManaged public var id: UUID
    @NSManaged var type: Int16
    @NSManaged var note: String
    @NSManaged var title: String
    @NSManaged var category: Category?
    @NSManaged var account: Account?
}

extension Transaction: Identifiable {}
