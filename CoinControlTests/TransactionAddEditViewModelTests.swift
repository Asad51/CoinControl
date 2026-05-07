//
//  TransactionAddEditViewModelTests.swift
//  CoinControlTests
//

@testable import CoinControl
import CoreData
import XCTest
import Combine

final class TransactionAddEditViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var transactionService: TransactionService!
    var viewModel: TransactionAddEditViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        let persistence = PersistenceController(inMemory: true)
        context = persistence.viewContext
        transactionService = TransactionService(context: context)
        cancellables = []
        
        // Seed some transactions with titles
        let titles = ["Coffee", "Grocery", "Gas", "Lunch"]
        for title in titles {
            let t = Transaction(context: context)
            t.id = UUID()
            t.title = title
            t.amount = 10.0
            t.date = Date()
            t.type = TransactionType.expense.rawValue
        }
        try context.save()
        
        viewModel = TransactionAddEditViewModel(transactionService: transactionService)
    }

    func testSuggestionsFilter() throws {
        // Given
        let expectation = XCTestExpectation(description: "Suggestions filtered")
        
        // When
        viewModel.title = "Co"
        
        // Then
        viewModel.$suggestions
            .dropFirst()
            .sink { suggestions in
                if suggestions.contains("Coffee") && suggestions.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSuggestionsEmptyOnNoMatch() throws {
        // When
        viewModel.title = "Xyz"
        
        // Then
        XCTAssertTrue(viewModel.suggestions.isEmpty)
    }
    
    func testSuggestionsEmptyOnEmptyInput() throws {
        // When
        viewModel.title = ""
        
        // Then
        XCTAssertTrue(viewModel.suggestions.isEmpty)
    }
    
    func testSuggestionsExcludesExactMatch() throws {
        // When
        viewModel.title = "Coffee"
        
        // Then
        XCTAssertFalse(viewModel.suggestions.contains("Coffee"), "Suggestions should not include the exact current title")
    }
}
