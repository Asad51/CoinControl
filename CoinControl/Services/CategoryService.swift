//
//  CategoryService.swift
//  CoinControl
//

import CoreData
import Foundation

protocol CategoryServiceProtocol {
    func fetchCategories() throws -> [Category]
}

class CategoryService: CategoryServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetchCategories() throws -> [Category] {
        let request = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return try context.fetch(request)
    }
}
