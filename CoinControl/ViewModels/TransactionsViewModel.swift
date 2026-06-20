//
//  TransactionsViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class TransactionsViewModel: NSObject, ObservableObject {
    @Published var groupedTransactions: [(Date, [Transaction])] = []
    @Published var yearlyTransactions: [(Date, [Transaction])] = []
    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var totalBalance: Double = 0
    @Published var selectedDate: Date = .init()

    @Published var monthlyIncome: Double = 0
    @Published var monthlyExpenses: Double = 0
    @Published var monthlyBalance: Double = 0

    @Published var monthlyExpenseCashAndBank: Double = 0.0
    @Published var monthlyExpenseCard: Double = 0.0
    @Published var expenseComparisonPercentage: Double = 0.0

    var expenseTrend: String {
        if expenseComparisonPercentage > 100 {
            return "increase"
        } else if expenseComparisonPercentage < 100, expenseComparisonPercentage > 0 {
            return "decrease"
        } else {
            return "stable"
        }
    }

    @Published var selectedMonthRangeString: String = ""

    @Published var searchQuery: String = ""
    @Published var filteredTransactions: [Transaction] = []
    @Published var isSearching: Bool = false

    @Published var showExportOptions = false
    @Published var exportedFileURL: URL?
    @Published var isExporting = false
    @Published var exportError: String?

    private let fetchedResultsController: NSFetchedResultsController<Transaction>
    private let transactionService: TransactionServiceProtocol
    private let exportService: ExportServiceProtocol
    let settings: Settings
    private var cancellables = Set<AnyCancellable>()

    init(
        transactionService: TransactionServiceProtocol = TransactionService(),
        exportService: ExportServiceProtocol = ExportService(),
        settings: Settings = Settings()
    ) {
        self.transactionService = transactionService
        self.exportService = exportService
        self.settings = settings
        fetchedResultsController = transactionService.getTransactionsFRC()

        super.init()
        fetchedResultsController.delegate = self

        setupSearchSubscriber()

        do {
            try fetchedResultsController.performFetch()
            updateGroupedTransactions()
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
    }

    private func setupSearchSubscriber() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        let allTransactions = fetchedResultsController.fetchedObjects ?? []
        if query.isEmpty {
            filteredTransactions = []
        } else {
            filteredTransactions = allTransactions.filter { transaction in
                let titleMatch = transaction.title.localizedCaseInsensitiveContains(query)
                let noteMatch = transaction.note.localizedCaseInsensitiveContains(query)
                let categoryMatch = transaction.category?.name.localizedCaseInsensitiveContains(query) == true ||
                    transaction.category?.icon.localizedCaseInsensitiveContains(query) == true
                let accountMatch = transaction.account?.name.localizedCaseInsensitiveContains(query) == true
                let amountMatch = String(format: "%.2f", transaction.amount).contains(query) ||
                    CurrencyFormatter.format(transaction.amount, currencySymbol: settings.currencySymbol).localizedCaseInsensitiveContains(query)

                return titleMatch || noteMatch || categoryMatch || accountMatch || amountMatch
            }
        }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    func nextYear() {
        if let newDate = Calendar.current.date(byAdding: .year, value: 1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    func previousYear() {
        if let newDate = Calendar.current.date(byAdding: .year, value: -1, to: selectedDate) {
            selectedDate = newDate
            updateGroupedTransactions()
        }
    }

    var selectedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: selectedDate)
    }

    var selectedYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedDate)
    }

    func updateGroupedTransactions() {
        let allTransactions = fetchedResultsController.fetchedObjects ?? []
        let calendar = Calendar.current

        let currentYearTransactions = allTransactions.filter {
            calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .year)
        }
        let yearlyGrouped = Dictionary(grouping: currentYearTransactions) { item in
            calendar.date(from: calendar.dateComponents([.year, .month], from: item.date))!
        }
        yearlyTransactions = yearlyGrouped.sorted { $0.key > $1.key }

        let monthlyTransactions = allTransactions.filter { transaction in
            calendar.isDate(transaction.date, equalTo: selectedDate, toGranularity: .month)
        }

        totalIncome = currentYearTransactions
            .filter { $0.type == TransactionType.income.rawValue }
            .reduce(0) { $0 + $1.amount }

        totalExpenses = currentYearTransactions
            .filter { $0.type == TransactionType.expense.rawValue }
            .reduce(0) { $0 + $1.amount }

        totalBalance = totalIncome - totalExpenses

        // Calculate Monthly Totals
        monthlyIncome = monthlyTransactions
            .filter { $0.type == TransactionType.income.rawValue }
            .reduce(0) { $0 + $1.amount }

        monthlyExpenses = monthlyTransactions
            .filter { $0.type == TransactionType.expense.rawValue }
            .reduce(0) { $0 + $1.amount }

        monthlyBalance = monthlyIncome - monthlyExpenses

        // Calculate Monthly Summary for Total View
        let monthlyExpensesList = monthlyTransactions.filter { $0.type == TransactionType.expense.rawValue }

        monthlyExpenseCashAndBank = monthlyExpensesList
            .filter { $0.account?.accountType != AccountType.card.rawValue }
            .reduce(0) { $0 + $1.amount }

        monthlyExpenseCard = monthlyExpensesList
            .filter { $0.account?.accountType == AccountType.card.rawValue }
            .reduce(0) { $0 + $1.amount }

        // Expense Comparison
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            let previousMonthExpenses = allTransactions.filter { transaction in
                calendar.isDate(transaction.date, equalTo: previousMonth, toGranularity: .month) &&
                    transaction.type == TransactionType.expense.rawValue
            }.reduce(0) { $0 + $1.amount }

            let currentMonthExpenses = monthlyExpensesList.reduce(0) { $0 + $1.amount }

            if previousMonthExpenses > 0 {
                expenseComparisonPercentage = (currentMonthExpenses / previousMonthExpenses) * 100
            } else {
                expenseComparisonPercentage = 0
            }
        }

        // Date Range String
        if let range = calendar.range(of: .day, in: .month, for: selectedDate),
           let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
           let lastDay = calendar.date(byAdding: .day, value: range.count - 1, to: firstDay)
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "M.d"
            selectedMonthRangeString = "\(formatter.string(from: firstDay)) ~ \(formatter.string(from: lastDay))"
        }

        let grouped = Dictionary(grouping: monthlyTransactions) { item in
            calendar.startOfDay(for: item.date)
        }
        groupedTransactions = grouped.sorted { $0.key > $1.key }
    }

    func exportData(for period: ExportPeriod) {
        isExporting = true
        exportError = nil

        Task {
            let allTransactions = fetchedResultsController.fetchedObjects ?? []
            let transactionsToExport: [Transaction]

            if let range = period.dateRange() {
                transactionsToExport = allTransactions.filter {
                    $0.date >= range.start && $0.date <= range.end
                }
            } else {
                transactionsToExport = allTransactions
            }

            let exportItems = transactionsToExport.map { transaction in
                let categoryDisplay = [transaction.category?.icon, transaction.category?.name]
                    .compactMap { $0 }
                    .joined(separator: " ")

                return TransactionExportItem(
                    date: transaction.date,
                    title: transaction.title,
                    type: TransactionType(rawValue: transaction.type)?.title ?? "Unknown",
                    category: categoryDisplay.isEmpty ? "No Category" : categoryDisplay,
                    account: transaction.account?.name ?? "No Account",
                    currency: settings.currencySymbol,
                    amount: transaction.amount,
                    note: transaction.note
                )
            }

            do {
                let url = try await exportService.exportTransactions(exportItems)
                await MainActor.run {
                    exportedFileURL = url
                    isExporting = false
                    showExportOptions = false
                }
            } catch {
                await MainActor.run {
                    print("Export failed: \(error)")
                    exportError = error.localizedDescription
                    isExporting = false
                }
            }
        }
    }
}

extension TransactionsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        updateGroupedTransactions()
    }
}
