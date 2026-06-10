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
    @EnvironmentObject private var settings: Settings

    @StateObject private var viewModel: TransactionAddEditViewModel

    @State private var showingDatePicker = false
    @State private var showingCategoryPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var tempDate = Date()
    @State private var suggestAbove = false

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

                    Text("\(viewModel.isEditing ? "Edit " : "")\(viewModel.transactionType.title)")
                        .font(.headline)
                        .padding(.leading, 10)

                    Spacer()

                    Button(viewModel.isEditing ? "Update" : "Save") {
                        viewModel.showErrors = true
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
                            VStack(alignment: .leading, spacing: 4) {
                                Button(action: { showingCategoryPicker = true }) {
                                    FormRowStyle(title: "Category",
                                                 value: viewModel.selectedCategory?.name ?? "",
                                                 hasContent: viewModel.selectedCategory != nil)
                                }
                                .buttonStyle(PlainButtonStyle())

                                if let error = viewModel.categoryError, viewModel.showErrors {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                }
                            }
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
                                    Text(settings.currencySymbol)
                                    TextField("0.00", text: $viewModel.amountText)
                                        .keyboardType(.decimalPad)
                                        .font(.system(.body, design: .monospaced))
                                }

                                Rectangle()
                                    .fill((viewModel.amountError != nil && viewModel.showErrors) ? Color.red : Color(UIColor.tertiaryLabel))
                                    .frame(height: 1)

                                if let error = viewModel.amountError, viewModel.showErrors {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 8)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Title")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                TextField("Title", text: $viewModel.title)

                                Rectangle()
                                    .fill((viewModel.titleError != nil && viewModel.showErrors) ? Color.red : Color(UIColor.label))
                                    .frame(height: 1)
                                    .overlay(alignment: .topLeading) {
                                        if !viewModel.suggestions.isEmpty {
                                            VStack(alignment: .leading, spacing: 0) {
                                                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                                                    Button(action: {
                                                        viewModel.title = suggestion
                                                    }) {
                                                        Text(suggestion)
                                                            .padding(.horizontal)
                                                            .padding(.vertical, 10)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .foregroundColor(.primary)
                                                    }
                                                    if suggestion != viewModel.suggestions.last {
                                                        Divider()
                                                    }
                                                }
                                            }
                                            .background(Color(UIColor.systemBackground))
                                            .cornerRadius(8)
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                            )
                                            .offset(y: suggestAbove ? -CGFloat(viewModel.suggestions.count * 40 + 50) : 5)
                                        }
                                    }

                                if let error = viewModel.titleError, viewModel.showErrors {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 8)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onChange(of: proxy.frame(in: .global).minY) { newValue in
                                            let screenHeight = UIScreen.main.bounds.height
                                            suggestAbove = newValue > screenHeight * 0.6
                                        }
                                }
                            )
                            .zIndex(1)

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
                                    showingDeleteConfirmation = true
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
                                .confirmationDialog(
                                    "Are you sure you want to delete this transaction?",
                                    isPresented: $showingDeleteConfirmation,
                                    titleVisibility: .visible
                                ) {
                                    Button("Delete", role: .destructive) {
                                        if viewModel.delete() {
                                            dismiss()
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
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
