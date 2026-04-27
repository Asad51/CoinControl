//
//  CategoryDetailView.swift
//  CoinControl
//
//  Created by Gemini CLI on 26/4/27.
//

import Charts
import SwiftUI

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CategoryDetailViewModel

    @State private var showingAddEditScreen = false
    @State private var selectedTransaction: Transaction?

    init(category: Category) {
        _viewModel = StateObject(wrappedValue: CategoryDetailViewModel(category: category))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                }

                HStack(spacing: 8) {
                    Text(viewModel.category.icon)
                        .font(.title3)
                    Text(viewModel.category.name)
                        .font(.headline)
                }
                .padding(.leading, 8)

                Spacer()

                HStack(spacing: 20) {
                    Button(action: { viewModel.navigate(direction: -1) }) {
                        Image(systemName: "chevron.left")
                    }

                    Text(viewModel.dateString)
                        .font(.subheadline).bold()

                    Button(action: { viewModel.navigate(direction: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .foregroundColor(.primary)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("৳ \(String(format: "%.2f", viewModel.totalAmount))")
                            .font(.title2).bold()
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Line Chart
                    if !viewModel.trendData.isEmpty {
                        Chart {
                            ForEach(viewModel.trendData) { point in
                                LineMark(
                                    x: .value("Month", point.date),
                                    y: .value("Amount", point.amount)
                                )
                                .interpolationMethod(.linear)
                                .foregroundStyle(.red)
                                .symbol(Circle())
                                .symbolSize(50)

                                AreaMark(
                                    x: .value("Month", point.date),
                                    y: .value("Amount", point.amount)
                                )
                                .interpolationMethod(.linear)
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.red.opacity(0.3), Color.red.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                            }
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .month)) { _ in
                                AxisValueLabel(format: .dateTime.month(.abbreviated))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let amount = value.as(Double.self) {
                                        Text("\(Int(amount / 1000))k")
                                    }
                                }
                                .foregroundStyle(.secondary)
                                AxisGridLine().foregroundStyle(.secondary.opacity(0.2))
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Transaction List
                    VStack(spacing: 0) {
                        ForEach(viewModel.groupedTransactions, id: \.0) { date, items in
                            DailySectionView(date: date, items: items) { transaction in
                                selectedTransaction = transaction
                                showingAddEditScreen = true
                            }
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddEditScreen, onDismiss: {
            viewModel.fetchData()
        }) {
            TransactionAddEditView(transactionToEdit: selectedTransaction)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
