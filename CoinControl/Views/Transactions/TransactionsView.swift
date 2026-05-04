//
//  TransactionsView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 18/4/26.
//

import CoreData
import SwiftUI

struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: TransactionsViewModel

    @State private var showingAddEditScreen = false
    @State private var selectedTransaction: Transaction?
    @State private var selectedTopTab = TransactionTopTab.daily
    @State private var previousIndex = 0
    private let topTabs = TransactionTopTab.allCases

    init() {
        _viewModel = StateObject(wrappedValue: TransactionsViewModel())
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // System background color (adapts to light/dark)
                Color(UIColor.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    TransactionHeaderView(viewModel: viewModel, selectedTopTab: Binding(
                        get: { selectedTopTab },
                        set: { newValue in
                            withAnimation(.spring) {
                                selectedTopTab = newValue
                            }
                        }
                    ))

                    if viewModel.isSearching {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.filteredTransactions) { transaction in
                                    TransactionRowView(item: transaction)
                                        .onTapGesture {
                                            selectedTransaction = transaction
                                            showingAddEditScreen = true
                                        }
                                    Divider()
                                }

                                if viewModel.filteredTransactions.isEmpty, !viewModel.searchQuery.isEmpty {
                                    Text("No transactions found")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 40)
                                }
                            }
                        }
                    } else {
                        ZStack {
                            Group {
                                switch selectedTopTab {
                                    case .calendar:
                                        TransactionCalendarView(viewModel: viewModel)
                                    case .monthly:
                                        TransactionMonthlyView(viewModel: viewModel)
                                    case .total:
                                        TransactionTotalView(viewModel: viewModel)
                                    default:
                                        ScrollView {
                                            LazyVStack(spacing: 0) {
                                                ForEach(viewModel.groupedTransactions, id: \.0) { date, dailyItems in
                                                    DailySectionView(date: date, items: dailyItems) { transaction in
                                                        // Handle row tap
                                                        selectedTransaction = transaction
                                                        showingAddEditScreen = true
                                                    }
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }

                VStack(spacing: 16) {
                    FloatingButton(systemImage: "plus") {
                        selectedTransaction = nil // Nil means "Add new"
                        showingAddEditScreen = true
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEditScreen) {
                TransactionAddEditView(transactionToEdit: selectedTransaction)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(items: \.transactions) { _ in
            TransactionsView()
        }
    }
#endif
