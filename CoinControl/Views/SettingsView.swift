//
//  SettingsView.swift
//  CoinControl
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: Settings

    @State private var showingFileImporter = false
    @State private var selectedFileURL: URL? = nil
    @State private var showingPreview = false

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

                    Button(action: {
                        showingFileImporter = true
                    }) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                }

                Section(header: Text("Appearance")) {
                    Text("Select Accent Color")
                        .font(.headline)
                        .padding(.vertical, 4)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                        ForEach(Settings.availableAccentColors, id: \.0) { name, color in
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
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.commaSeparatedText, .text],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            selectedFileURL = url
                            showingPreview = true
                        }
                    case .failure(let error):
                        CCLogger.error("Failed to select file: \(error.localizedDescription)")
                }
            }
            .sheet(isPresented: $showingPreview, onDismiss: {
                selectedFileURL = nil
            }) {
                if let url = selectedFileURL {
                    ImportPreviewView(fileURL: url)
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
