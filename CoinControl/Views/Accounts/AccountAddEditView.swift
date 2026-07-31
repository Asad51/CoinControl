//
//  AccountAddEditView.swift
//  CoinControl
//

import SwiftUI

struct AccountAddEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AccountsViewModel
    var accountToEdit: AccountModel?

    @State private var name = ""
    @State private var type = AccountType.cash
    @State private var showingDeleteConfirmation = false

    private var isEditing: Bool {
        accountToEdit != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Details")) {
                    TextField("Account Name", text: $name)
                        .autocorrectionDisabled()

                    Picker("Account Type", selection: $type) {
                        ForEach(AccountType.allCases) { accountType in
                            Text(accountType.title).tag(accountType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 4)
                }

                if isEditing {
                    Section {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Delete Account")
                                    .foregroundColor(.appExpense)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                        .foregroundColor(.appExpense)
                        .confirmationDialog(
                            "Are you sure you want to delete this account?",
                            isPresented: $showingDeleteConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Delete", role: .destructive) {
                                if let account = accountToEdit {
                                    viewModel.deleteAccount(account)
                                    dismiss()
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Account" : "Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Update" : "Save") {
                        if let account = accountToEdit {
                            viewModel.updateAccount(id: account.id, name: name, type: type)
                        } else {
                            viewModel.addAccount(name: name, type: type)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let account = accountToEdit {
                    name = account.name
                    type = account.type
                }
            }
        }
    }
}
