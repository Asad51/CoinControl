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
    @State private var selectedTopTab = "Daily"

    init() {
        _viewModel = StateObject(wrappedValue: TransactionsViewModel())
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // System background color (adapts to light/dark)
                Color(UIColor.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    TransactionHeaderView(viewModel: viewModel, selectedTopTab: $selectedTopTab)

                    switch selectedTopTab {
                        case "Calendar":
                            TransactionCalendarView(viewModel: viewModel)
                        case "Monthly":
                            TransactionMonthlyView(viewModel: viewModel)
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
