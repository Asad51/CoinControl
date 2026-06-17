//
//  EmptyStateView.swift
//  CoinControl
//

import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject private var settings: Settings
    let systemImage: String
    let title: String
    let message: String

    init(
        systemImage: String,
        title: String,
        message: String
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.3))
                .padding(.bottom, 10)

            VStack(spacing: 12) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 50) // Adjust for potential tab bar or floating buttons
    }
}

#Preview {
    EmptyStateView(
        systemImage: "tray.fill",
        title: "No Transactions",
        message: "No transactions this month — tap + to add your first expense."
    )
}
