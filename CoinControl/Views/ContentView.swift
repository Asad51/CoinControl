//
//  ContentView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 25/1/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: Settings
    @State private var selectedTab = BottomTab.transactions

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            VStack {
                ZStack(alignment: .bottomTrailing) {
                    TabView(selection: $selectedTab) {
                        TransactionsView(settings: settings)
                            .tag(BottomTab.transactions)

                        StatsView()
                            .tag(BottomTab.stats)

                        AccountsView()
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
        CoreDataPreview(items: \.transactions) { _ in
            ContentView()
        }
    }
#endif
