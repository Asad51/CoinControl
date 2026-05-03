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
    @State private var tempDate = Date()

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
                            Button(action: {
                                tempDate = viewModel.date
                                showingDatePicker = true
                            }) {
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
                                VStack(spacing: 0) {
                                    DatePicker("", selection: $tempDate, displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.graphical)
                                        .padding()

                                    Divider()

                                    HStack {
                                        Button("Cancel") {
                                            showingDatePicker = false
                                        }
                                        .foregroundColor(.red)

                                        Spacer()

                                        Button("Okay") {
                                            viewModel.date = tempDate
                                            showingDatePicker = false
                                        }
                                        .fontWeight(.bold)
                                    }
                                    .padding()
                                }
                                .frame(width: 350)
                            }

                            // Account row - with Dropdown Menu selection
                            ZStack(alignment: .leading) {
                                FormRowStyle(title: "Account",
                                             value: viewModel.selectedAccount?.name ?? "",
                                             hasContent: viewModel.selectedAccount != nil)

                                Menu {
                                    ForEach(viewModel.accounts) { account in
                                        Button(account.name, action: { viewModel.selectedAccount = account })
                                    }
                                } label: {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.001))
                                }
                            }

                            // Category row - opens CategoryGrid sheet
                            Button(action: { showingCategoryPicker = true }) {
                                FormRowStyle(title: "Category",
                                             value: viewModel.selectedCategory?.name ?? "",
                                             hasContent: viewModel.selectedCategory != nil)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .sheet(isPresented: $showingCategoryPicker) {
                                // sheet is automatically wrapped in NavigationView with CategoryGridView
                                CategoryGridView(selectedCategory: $viewModel.selectedCategory, type: viewModel.transactionType.rawValue)
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

                            if viewModel.isEditing {
                                Button(action: {
                                    if viewModel.delete() {
                                        dismiss()
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Delete Transaction")
                                            .foregroundColor(.red)
                                            .fontWeight(.medium)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 40)
                            }
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
