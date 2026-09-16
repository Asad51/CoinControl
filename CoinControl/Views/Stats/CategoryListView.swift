//
//  CategoryListView.swift
//  CoinControl
//

import SwiftUI

struct CategoryListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CategoryListViewModel
    @State private var showingAddSheet = false

    init(type: Int16) {
        _viewModel = StateObject(wrappedValue: CategoryListViewModel(type: type))
    }

    var body: some View {
        List {
            ForEach(viewModel.categories) { category in
                HStack(spacing: 16) {
                    Text(category.icon)
                        .font(.title3)
                        .frame(width: 32, height: 32)

                    Text(category.name)
                        .font(.body)

                    Spacer()
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: viewModel.deleteCategory)
        }
        .navigationTitle("\(TransactionType(rawValue: viewModel.type)?.title ?? "") Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CategoryAddView(viewModel: viewModel)
        }
        .alert("Can’t Delete Category", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct CategoryAddView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoryListViewModel

    @State private var name = ""
    @State private var icon = "✨"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Info")) {
                    TextField("Name", text: $name)
                    TextField("Icon (Emoji)", text: $icon)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addCategory(name: name, icon: icon)
                        dismiss()
                    }
                    .disabled(name.isEmpty || icon.isEmpty)
                }
            }
        }
    }
}
