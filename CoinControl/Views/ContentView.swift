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
    @StateObject private var statsViewModel: StatsViewModel
    @StateObject private var accountsViewModel: AccountsViewModel
    @State private var selectedTab = BottomTab.transactions

    init(settings: Settings = Settings()) {
        _transactionsViewModel = StateObject(wrappedValue: TransactionsViewModel(settings: settings))
        _statsViewModel = StateObject(wrappedValue: StatsViewModel())
        _accountsViewModel = StateObject(wrappedValue: AccountsViewModel())
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
                            StatsView(viewModel: statsViewModel)
                        case .accounts:
                            AccountsView(viewModel: accountsViewModel)
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
