//
//  ContentView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 25/1/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = BottomTab.records

    var body: some View {
        ZStack {
            Color.l22Df7
                .ignoresSafeArea()

            VStack {
                ZStack(alignment: .bottomTrailing) {
                    TabView(selection: $selectedTab) {
                        Text("Transaction")
                            .tag(BottomTab.records)

                        Text("Summary")
                            .tag(BottomTab.stats)

                        Text("Accounts")
                            .tag(BottomTab.accounts)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }

                Spacer()

                BottomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(\.records) {
            ContentView()
        }
    }
#endif
