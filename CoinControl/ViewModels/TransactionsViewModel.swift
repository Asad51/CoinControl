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

    @Published var monthlyExpenseCashAndBank: Double = 0
    @Published var monthlyExpenseCard: Double = 0
    @Published var monthlyTransfer: Double = 0
    @Published var expenseComparisonPercentage: Double = 0
    @Published var selectedMonthRangeString: String = ""

    @Published var searchQuery: String = ""
    @Published var filteredTransactions: [Transaction] = []
    @Published var isSearching: Bool = false

    private let fetchedResultsController: NSFetchedResultsController<Transaction>
    private let transactionService: TransactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(transactionService: TransactionServiceProtocol = TransactionService()) {
        self.transactionService = transactionService
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
            filteredTransactions = allTransactions.filter {
                $0.title.localizedCaseInsensitiveContains(query)
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
            .filter { $0.account?.name != "Credit Card" }
            .reduce(0) { $0 + $1.amount }

        monthlyExpenseCard = monthlyExpensesList
            .filter { $0.account?.name == "Credit Card" }
            .reduce(0) { $0 + $1.amount }

        monthlyTransfer = monthlyTransactions
            .filter { $0.type == TransactionType.transfer.rawValue }
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
}

extension TransactionsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        updateGroupedTransactions()
    }
}
