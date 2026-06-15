//
//  TransactionsView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 18/4/26.
//

import CoreData
import SwiftUI

struct TransactionEditContainer: Identifiable {
    let id = UUID()
    let transaction: Transaction?
}

struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var settings: Settings
    @ObservedObject private var viewModel: TransactionsViewModel

    @State private var sheetContainer: TransactionEditContainer?
    @State private var selectedTopTab = TransactionTopTab.daily
    @State private var previousIndex = 0
    private let topTabs = TransactionTopTab.allCases

    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
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
                                            sheetContainer = TransactionEditContainer(transaction: transaction)
                                        }
                                    Divider()
                                }

                                if viewModel.filteredTransactions.isEmpty, !viewModel.searchQuery.isEmpty {
                                    EmptyStateView(
                                        systemImage: "magnifyingglass",
                                        title: "No results found",
                                        message: "We couldn't find any transactions matching \"\(viewModel.searchQuery)\"."
                                    )
                                    .padding(.top, 60)
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
                                        if viewModel.groupedTransactions.isEmpty {
                                            EmptyStateView(
                                                systemImage: "tray",
                                                title: "No transactions this month",
                                                message: "Tap + to add your first expense.",
                                                buttonTitle: "Add Transaction"
                                            ) {
                                                sheetContainer = TransactionEditContainer(transaction: nil)
                                            }
                                        } else {
                                            ScrollView {
                                                LazyVStack(spacing: 0) {
                                                    ForEach(viewModel.groupedTransactions, id: \.0) { date, dailyItems in
                                                        DailySectionView(date: date, items: dailyItems) { transaction in
                                                            // Handle row tap
                                                            sheetContainer = TransactionEditContainer(transaction: transaction)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .blur(radius: viewModel.showExportOptions ? 3 : 0)
                .disabled(viewModel.showExportOptions)

                VStack(spacing: 16) {
                    FloatingButton(systemImage: "plus") {
                        sheetContainer = TransactionEditContainer(transaction: nil)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .blur(radius: viewModel.showExportOptions ? 3 : 0)
                .disabled(viewModel.showExportOptions)

                if viewModel.showExportOptions {
                    ExportOptionsView(isPresented: $viewModel.showExportOptions) { period in
                        viewModel.exportData(for: period)
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.spring(), value: viewModel.showExportOptions)
            .navigationBarHidden(true)
            .sheet(item: $sheetContainer) { container in
                TransactionAddEditView(transactionToEdit: container.transaction)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(item: $viewModel.exportedFileURL, onDismiss: {
                viewModel.exportedFileURL = nil
            }) { url in
                ShareSheet(activityItems: [url])
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(items: \.transactions) { _ in
            TransactionsView(viewModel: TransactionsViewModel())
        }
    }
#endif
