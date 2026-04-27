//
//  Category+CoreDataProperties.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 19/4/26.
//
//

import CoreData
import Foundation

public typealias CategoryCoreDataPropertiesSet = NSSet

extension Category {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Category> {
        NSFetchRequest<Category>(entityName: "CategoryEntity")
    }

    @NSManaged var desc: String
    @NSManaged var icon: String
    @NSManaged public var id: UUID
    @NSManaged var name: String
    @NSManaged var type: Int16
    @NSManaged var transactions: NSSet
}

// MARK: Generated accessors for transactions

extension Category {
    @objc(addTransactionsObject:)
    @NSManaged func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged func removeFromTransactions(_ values: NSSet)
}

extension Category: Identifiable {}
