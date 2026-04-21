//
//  TransactionAddEditView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 19/4/26.
//

import CoreData
import SwiftUI

struct TransactionAddEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: TransactionAddEditViewModel

    @State private var showingDatePicker = false
    @State private var showingCategoryPicker = false

    private var customDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy (E) h:mm a"
        return formatter
    }

    init(transactionToEdit: Transaction? = nil) {
        _viewModel = StateObject(wrappedValue: TransactionAddEditViewModel(
            transactionToEdit: transactionToEdit
        ))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                    }

                    Text(viewModel.isEditing ? "Edit Expense" : "Expense")
                        .font(.headline)
                        .padding(.leading, 10)

                    Spacer()

                    Button(viewModel.isEditing ? "Update" : "Save") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                }
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Picker("Transaction Type", selection: $viewModel.transactionType) {
                            ForEach(TransactionType.allCases) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accentColor(viewModel.transactionType == .expense ? .red : .accentColor)
                        .padding(.horizontal)
                        .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 0) {
                            // Date row with refresh icon
                            Button(action: { showingDatePicker = true }) {
                                HStack {
                                    FormRowStyle(title: "Date",
                                                 value: customDateFormatter.string(from: viewModel.date),
                                                 hasContent: true)
                                    Spacer()
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .popover(isPresented: $showingDatePicker) {
                                DatePicker("", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.graphical)
                                    .frame(width: 350)
                            }

                            // Account row - with Dropdown Menu selection
                            Menu {
                                // Dynamic options from fetched results
                                ForEach(viewModel.accounts) { account in
                                    Button(account.name, action: { viewModel.selectedAccount = account })
                                }
                            } label: {
                                FormRowStyle(title: "Account",
                                             value: viewModel.selectedAccount?.name ?? "",
                                             // Account is underlined red in your image when selected
                                             hasContent: viewModel.selectedAccount != nil)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Category row - opens CategoryGrid sheet
                            Button(action: { showingCategoryPicker = true }) {
                                FormRowStyle(title: "Category",
                                             value: viewModel.selectedCategory?.name ?? "",
                                             hasContent: viewModel.selectedCategory != nil)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .sheet(isPresented: $showingCategoryPicker) {
                                // sheet is automatically wrapped in NavigationView with CategoryGridView
                                CategoryGridView(selectedCategory: $viewModel.selectedCategory)
                                    .environment(\.managedObjectContext, viewContext)
                            }

                            // Amount text field - using a text field for input.
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Amount")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack {
                                    Text("৳") // Taka currency symbol
                                    TextField("0.00", text: $viewModel.amountText)
                                        .keyboardType(.decimalPad)
                                        .font(.system(.body, design: .monospaced))
                                }

                                Rectangle()
                                    .fill(Color(UIColor.tertiaryLabel))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 8)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Title")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                TextField("Title", text: $viewModel.title)

                                Rectangle()
                                    .fill(Color(UIColor.label))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 8)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Note")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                TextField("Optional notes", text: $viewModel.note)

                                Rectangle()
                                    .fill(Color(UIColor.label))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(item: \.transaction) { _ in
            TransactionAddEditView()
        }
    }
#endif
