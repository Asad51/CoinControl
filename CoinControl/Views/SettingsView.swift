//
//  SettingsView.swift
//  CoinControl
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: Settings

    private let availableColors: [(String, Color)] = [
        ("Blue", .tintBlue),
        ("Green", .tintGreen),
        ("Navy", .tintNavy),
        ("Orange", .tintOrange),
        ("Pink", .tintPink),
        ("Violet", .tintViolet),
    ]

    private let currencies = ["৳", "$", "€", "£", "¥", "₹"]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Currency")) {
                    Picker("Currency Symbol", selection: $settings.currencySymbol) {
                        ForEach(currencies, id: \.self) { symbol in
                            Text(symbol).tag(symbol)
                        }
                    }
                }

                Section(header: Text("Data Management")) {
                    NavigationLink(destination: CategoryListView(type: TransactionType.income.rawValue)) {
                        Label("Income Categories", systemImage: "arrow.down.circle")
                    }

                    NavigationLink(destination: CategoryListView(type: TransactionType.expense.rawValue)) {
                        Label("Expense Categories", systemImage: "arrow.up.circle")
                    }
                }

                Section(header: Text("Appearance")) {
                    Text("Select Accent Color")
                        .font(.headline)
                        .padding(.vertical, 4)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(availableColors, id: \.0) { name, color in
                            VStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: settings.isSelected(colorName: name) ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            settings.setAccentColor(name: name)
                                        }
                                    }

                                Text(name)
                                    .font(.caption2)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        SettingsView()
            .environmentObject(Settings())
    }
#endif

