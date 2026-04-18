//
//  ContentView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 25/1/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = BottomTab.transactions

    var body: some View {
        ZStack {
            Color.l22Df7
                .ignoresSafeArea()

            VStack {
                ZStack(alignment: .bottomTrailing) {
                    TabView(selection: $selectedTab) {
                        TransactionsView()
                            .tag(BottomTab.transactions)

                        Text("Summary")
                            .tag(BottomTab.stats)

                        Text("Accounts")
                            .tag(BottomTab.accounts)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }

                Spacer()

                BottomTabView(selectedTab: $selectedTab)
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(\.transactions) { _ in
            ContentView()
        }
    }
#endif
