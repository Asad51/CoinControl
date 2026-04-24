//
//  StatsView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import Charts
import SwiftUI

/// The main statistics view that provides an overview of expenses by category.
struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()

    /// Holds the raw value of the selected angle in the pie chart.
    @State private var selectedStatValue: Double? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header navigation: Period selection and date range display
                HStack {
                    Button(action: { viewModel.navigate(direction: -1) }) {
                        Image(systemName: "chevron.left")
                    }

                    Text(viewModel.dateRangeString)
                        .font(.headline)
                        .frame(minWidth: 120)

                    Button(action: { viewModel.navigate(direction: 1) }) {
                        Image(systemName: "chevron.right")
                    }

                    Spacer()

                    // Period Picker (Weekly, Monthly, Annually, etc.)
                    Menu {
                        Picker("Period", selection: $viewModel.selectedPeriod) {
                            ForEach(StatsPeriod.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedPeriod.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    .onChange(of: viewModel.selectedPeriod) { _ in
                        viewModel.updateDateRange()
                    }
                }
                .padding()

                // Income/Expense Summary Toggles
                HStack(spacing: 0) {
                    Text("Income")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)

                    VStack(spacing: 8) {
                        Text("Expenses ৳ \(String(format: "%.2f", viewModel.totalExpenses))")
                            .fontWeight(.bold)
                        Rectangle()
                            .fill(Color.red)
                            .frame(height: 3)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top)

                ScrollView {
                    VStack(spacing: 30) {
                        // Pie chart breakdown of expenses by category
                        CategoryPieChartView(stats: viewModel.stats, selectedStatValue: $selectedStatValue)

                        // Detailed list of category statistics
                        VStack(spacing: 0) {
                            ForEach(viewModel.stats) { stat in
                                StatRow(stat: stat)
                                Divider()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(items: \.transactions) { _ in
            StatsView()
        }
    }
#endif
