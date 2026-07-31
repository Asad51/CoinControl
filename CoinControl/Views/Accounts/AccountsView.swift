//
//  AccountsView.swift
//  CoinControl
//

import SwiftUI

struct AccountEditContainer: Identifiable {
    let id = UUID()
    let account: AccountModel?
}

struct AccountsView: View {
    @EnvironmentObject private var settings: Settings
    @StateObject private var viewModel = AccountsViewModel()
    @State private var sheetContainer: AccountEditContainer?

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
                            Button(action: {
                                sheetContainer = AccountEditContainer(account: account)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(account.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(account.type.title)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Text(CurrencyFormatter.format(viewModel.balances[account.id] ?? 0.0, currencySymbol: settings.currencySymbol))
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor((viewModel.balances[account.id] ?? 0.0) >= 0 ? .appTotal : .appExpense)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        sheetContainer = AccountEditContainer(account: nil)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $sheetContainer) { container in
                AccountAddEditView(viewModel: viewModel, accountToEdit: container.account)
            }
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
