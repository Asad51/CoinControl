//
//  ImportPreviewView.swift
//  CoinControl
//

import SwiftUI

struct ImportPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: Settings
    @StateObject private var viewModel = ImportViewModel()
    let fileURL: URL

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Processing data...")
                            .foregroundColor(.secondary)
                    }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.appExpense)
                        Text("Import Failed")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Close") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                } else if viewModel.importCompleted {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.appIncome)
                        Text("Import Completed")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Successfully imported \(viewModel.importedCount) transactions.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                } else {
                    VStack(spacing: 0) {
                        // Summary card
                        summaryHeader
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))

                        // Selection tools
                        HStack {
                            Button("Select All") {
                                viewModel.selectAll()
                            }
                            .font(.subheadline)
                            
                            Spacer()
                            
                            Button("Deselect All") {
                                viewModel.deselectAll()
                            }
                            .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        Divider()

                        // List of parsed transactions
                        List {
                            ForEach(viewModel.parsedItems) { item in
                                transactionRow(for: item)
                            }
                        }
                        .listStyle(PlainListStyle())

                        // Confirm Import Bar
                        confirmBar
                    }
                }
            }
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                viewModel.loadAndParseFile(url: fileURL)
            }
        }
    }

    private var summaryHeader: some View {
        HStack(spacing: 15) {
            let total = viewModel.parsedItems.count
            let selected = viewModel.parsedItems.filter { $0.isSelected }.count
            let duplicates = viewModel.parsedItems.filter { $0.isDuplicate }.count
            let newCats = viewModel.parsedItems.filter { $0.isNewCategory }.count
            let newAccs = viewModel.parsedItems.filter { $0.isNewAccount }.count

            VStack(alignment: .leading, spacing: 6) {
                Text("File Summary")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("\(total) parsed")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(selected) selected")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                        .frame(height: 35)

                    VStack(alignment: .leading) {
                        if duplicates > 0 {
                            Text("\(duplicates) duplicates")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        if newCats > 0 {
                            Text("\(newCats) new categories")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        if newAccs > 0 {
                            Text("\(newAccs) new accounts")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                        if duplicates == 0 && newCats == 0 && newAccs == 0 {
                            Text("All categories/accounts match")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Spacer()
        }
    }

    private func transactionRow(for item: ParsedTransactionItem) -> some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                viewModel.toggleSelection(for: item.id)
            }) {
                Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isSelected ? settings.accentColor : .secondary)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.body)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(CurrencyFormatter.format(item.amount, currencySymbol: settings.currencySymbol))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(item.type == .income ? .appIncome : .appExpense)
                }

                HStack(spacing: 8) {
                    Text(dateFormatter.string(from: item.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(item.categoryName) • \(item.accountName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Badges
                if item.isDuplicate || item.isNewCategory || item.isNewAccount {
                    HStack(spacing: 6) {
                        if item.isDuplicate {
                            badge(text: "Duplicate", bg: .orange.opacity(0.15), fg: .orange)
                        }
                        if item.isNewCategory {
                            badge(text: "New Category", bg: .blue.opacity(0.15), fg: .blue)
                        }
                        if item.isNewAccount {
                            badge(text: "New Account", bg: .purple.opacity(0.15), fg: .purple)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .opacity(item.isSelected ? 1.0 : 0.5)
        }
        .padding(.vertical, 4)
    }

    private func badge(text: String, bg: Color, fg: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(bg)
            .foregroundColor(fg)
            .cornerRadius(4)
    }

    private var confirmBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            let selectedCount = viewModel.parsedItems.filter { $0.isSelected }.count
            
            Button(action: {
                viewModel.confirmImport()
            }) {
                Text(selectedCount > 0 ? "Confirm Import (\(selectedCount) items)" : "Select items to Import")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedCount > 0 ? settings.accentColor : Color.secondary.opacity(0.3))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .cornerRadius(8)
            }
            .disabled(selectedCount == 0 || viewModel.isLoading)
            .padding()
        }
        .background(Color(UIColor.systemBackground))
    }
}
