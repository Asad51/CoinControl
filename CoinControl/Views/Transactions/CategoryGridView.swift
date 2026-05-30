//
//  CategoryGridView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 19/4/26.
//

import CoreData
import SwiftUI

struct CategoryGridView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: CategoryGridViewModel

    // Pass selection back to main view
    @Binding var selectedCategory: Category?
    let type: Int16
    
    @State private var showingEditSheet = false

    // 3-column grid structure matching your image
    private var gridItems: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }

    init(selectedCategory: Binding<Category?>, type: Int16) {
        _selectedCategory = selectedCategory
        self.type = type
        _viewModel = StateObject(wrappedValue: CategoryGridViewModel(type: type))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header custom toolbar from image 2
                HStack {
                    Text("Category")
                        .font(.headline)

                    Spacer()

                    HStack(spacing: 20) {
                        Button(action: { showingEditSheet = true }) {
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .foregroundColor(.primary)
                .padding()

                Divider()

                ScrollView {
                    if viewModel.categories.isEmpty {
                        EmptyStateView(
                            systemImage: "list.bullet.indent",
                            title: "No categories",
                            message: "It seems there are no categories for this transaction type."
                        )
                        .padding(.top, 60)
                    } else {
                        // Category Grid
                        LazyVGrid(columns: gridItems, spacing: 1) {
                            ForEach(viewModel.categories) { category in
                                Button {
                                    selectedCategory = category
                                    dismiss()
                                } label: {
                                    VStack(spacing: 12) {
                                        // Custom visual: Icon on colored circle background
                                        Text(category.icon)
                                            .font(.system(size: 24))
                                            .frame(width: 44, height: 44)
                                            .clipShape(Circle())

                                        Text(category.name)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(1)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    // Add border to create grid appearance from your image
                                    .border(Color(UIColor.separator).opacity(0.5), width: 0.5)
                                }
                            }
                        }
                        .padding(1) // Adjust for grid border
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditSheet, onDismiss: {
                viewModel.fetchCategories()
            }) {
                CategoryListView(type: type)
            }
        }
    }
}
