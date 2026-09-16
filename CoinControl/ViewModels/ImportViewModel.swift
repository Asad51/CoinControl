//
//  ImportViewModel.swift
//  CoinControl
//

import Combine
import Foundation

@MainActor
class ImportViewModel: ObservableObject {
    @Published var parsedItems: [ParsedTransactionItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var importCompleted = false
    @Published var importedCount = 0

    private let importService: ImportServiceProtocol
    private var hasLoadedFile = false

    init(importService: ImportServiceProtocol = ImportService()) {
        self.importService = importService
    }

    func loadAndParseFile(url: URL) {
        // `onAppear` can fire more than once; only parse the file the first time
        // so the user's selection state isn't discarded.
        guard !hasLoadedFile else { return }
        hasLoadedFile = true

        isLoading = true
        errorMessage = nil
        importCompleted = false
        
        // CSV files might need permission to read
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            self.parsedItems = try importService.parseTransactions(from: url)
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    func toggleSelection(for itemId: UUID) {
        if let index = parsedItems.firstIndex(where: { $0.id == itemId }) {
            parsedItems[index].isSelected.toggle()
        }
    }

    func selectAll() {
        for index in 0..<parsedItems.count {
            parsedItems[index].isSelected = true
        }
    }

    func deselectAll() {
        for index in 0..<parsedItems.count {
            parsedItems[index].isSelected = false
        }
    }

    func confirmImport() {
        guard !parsedItems.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let selectedItems = parsedItems.filter { $0.isSelected }
            try importService.importTransactions(selectedItems)
            self.importedCount = selectedItems.count
            self.importCompleted = true
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
