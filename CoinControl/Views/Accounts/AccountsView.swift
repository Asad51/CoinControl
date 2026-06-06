//
//  AccountsView.swift
//  CoinControl
//

import SwiftUI

struct AccountsView: View {
    @StateObject private var viewModel = AccountsViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.accounts.isEmpty {
                    EmptyStateView(
                        systemImage: "creditcard",
                        title: "No accounts found",
                        message: "It seems you don't have any accounts set up yet."
                    )
                } else {
                    List {
                        ForEach(viewModel.accounts) { account in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(account.name)
                                        .font(.headline)
                                }

                                Spacer()

                                Text(CurrencyFormatter.format(viewModel.balances[account.id] ?? 0.0))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor((viewModel.balances[account.id] ?? 0.0) >= 0 ? .primary : .red)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(items: \.accounts) { _ in
            AccountsView()
        }
    }
#endif
