//
//  CategoryGridViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class CategoryGridViewModel: ObservableObject {
    @Published var categories: [Category] = []

    private let categoryService: CategoryServiceProtocol
    private let type: Int16

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
}
