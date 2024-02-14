//
//  Category+CoreDataProperties.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 14/2/24.
//
//

import CoreData
import Foundation

public extension Category {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged var name: String
    @NSManaged var slug: String
}

extension Category: Identifiable {}
