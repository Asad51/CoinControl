//
//  CategoryListViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class CategoryListViewModel: ObservableObject {
    @Published var categories: [Category] = []

    private let categoryService: CategoryServiceProtocol
    let type: Int16

    init(type: Int16, categoryService: CategoryServiceProtocol = CategoryService()) {
        self.type = type
        self.categoryService = categoryService
        fetchCategories()
    }

    func fetchCategories() {
        do {
            categories = try categoryService.fetchCategories(by: type)
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }

    func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            do {
                try categoryService.deleteCategory(category)
                fetchCategories()
            } catch {
                print("Failed to delete category: \(error)")
            }
        }
    }

    func addCategory(name: String, icon: String) {
        do {
            try categoryService.addCategory(name: name, icon: icon, type: type)
            fetchCategories()
        } catch {
            print("Failed to add category: \(error)")
        }
    }
}
