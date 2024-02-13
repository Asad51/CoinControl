//
//  BottomTabBar.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 13/2/24.
//

import SwiftUI

struct BottomTabBar: View {
    @EnvironmentObject private var settings: Settings

    @Binding var selectedTab: BottomTab

    var body: some View {
        HStack {
            ForEach(BottomTab.allCases, id: \.hashValue) { tab in
                VStack {
                    Image(systemName: tab.systemImage)
                        .font(.subheadline)

                    Text(tab.rawValue.capitalized)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(tab == selectedTab ? settings.accentColor : .gray)
                .padding(.top)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(tab == selectedTab ? Color.accentColor : .clear)
                        .frame(width: 50, height: 5)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedTab = tab
                    }
                }
            }
        }
        .background(settings.accentColor.opacity(0.1))
        .overlay(
            Rectangle()
                .fill(settings.accentColor.opacity(0.2))
                .frame(height: 1),
            alignment: .top
        )
    }
}

#Preview {
    ZStack {
        Color.l22Df7
            .ignoresSafeArea()

        VStack(spacing: 0) {
            Spacer()
            BottomTabBar(selectedTab: .constant(BottomTab.records))
        }
    }
    .environmentObject(Settings())
}
