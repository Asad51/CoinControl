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

    // Fetch transactions sorted by date descending
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default
    )
    private var transactions: FetchedResults<Transaction>

    @State private var showingAddEditScreen = false
    @State private var selectedTransaction: Transaction?

    // Group transactions by Date
    var groupedTransactions: [(Date, [Transaction])] {
        let grouped = Dictionary(grouping: Array(transactions)) { item in
            Calendar.current.startOfDay(for: item.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                // Standard system background color (adapts to light/dark)
                Color(UIColor.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // HeaderView()
                    // SummaryView(transactions: Array(transactions))

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedTransactions, id: \.0) { date, dailyItems in
                                DailySectionView(date: date, items: dailyItems) { transaction in
                                    // Handle row tap
                                    selectedTransaction = transaction
                                    showingAddEditScreen = true
                                }
                            }
                        }
                    }
                }

                FloatingButton(systemImage: "plus") {
                    selectedTransaction = nil // Nil means "Add new"
                    showingAddEditScreen = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEditScreen) {
                // Placeholder for your future Add/Edit screen
                Text(selectedTransaction == nil ? "Add Transaction View" : "Edit Transaction View")
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(\.transactions) { _ in
            TransactionsView()
        }
    }
#endif
