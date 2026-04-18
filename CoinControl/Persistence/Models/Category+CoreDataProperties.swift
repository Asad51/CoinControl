//
//  Category+CoreDataProperties.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 18/4/26.
//
//

public import Foundation
public import CoreData

public typealias CategoryCoreDataPropertiesSet = NSSet

extension Category {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "CategoryEntity")
    }

    @NSManaged public var name: String
    @NSManaged public var id: UUID
    @NSManaged public var icon: String
    @NSManaged public var desc: String
    @NSManaged public var transactions: NSSet
}

// MARK: Generated accessors for transactions
extension Category {

    @objc(addTransactionsObject:)
    @NSManaged public func addToTransactions(_ value: Transaction)

    @objc(removeTransactionsObject:)
    @NSManaged public func removeFromTransactions(_ value: Transaction)

    @objc(addTransactions:)
    @NSManaged public func addToTransactions(_ values: NSSet)

    @objc(removeTransactions:)
    @NSManaged public func removeFromTransactions(_ values: NSSet)

}

extension Category : Identifiable {

}
