//
//  ContentView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 25/1/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: Settings
    @StateObject private var transactionsViewModel: TransactionsViewModel
    @State private var selectedTab = BottomTab.transactions

    init() {
        // Initialize with default settings; it will be updated if needed or we can rely on @EnvironmentObject in the view
        _transactionsViewModel = StateObject(wrappedValue: TransactionsViewModel())
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                        case .transactions:
                            TransactionsView(viewModel: transactionsViewModel)
                        case .stats:
                            StatsView()
                        case .accounts:
                            AccountsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity) // Smooth transition between views

                BottomTabView(selectedTab: $selectedTab)
                    .disabled(transactionsViewModel.showExportOptions)
                    .opacity(transactionsViewModel.showExportOptions ? 0.5 : 1.0)
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(items: \.transactions) { _ in
            ContentView()
        }
    }
#endif
