//
//  AccountsView.swift
//  CoinControl
//

import SwiftUI

struct AccountsView: View {
    @StateObject private var viewModel = AccountsViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.accounts) { account in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                        }

                        Spacer()

                        Text("৳ \(String(format: "%.2f", viewModel.balances[account.id] ?? 0.0))")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor((viewModel.balances[account.id] ?? 0.0) >= 0 ? .primary : .red)
                    }
                    .padding(.vertical, 4)
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
