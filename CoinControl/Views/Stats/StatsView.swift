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
    @EnvironmentObject private var settings: Settings
    @StateObject private var viewModel = StatsViewModel()

    /// Holds the raw value of the selected angle in the pie chart.
    @State private var selectedStatValue: Double? = nil
    @State private var showingDatePicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header navigation: Period selection and date range display
                HStack {
                    Button(action: { viewModel.navigate(direction: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(viewModel.selectedPeriod == .period)
                    .opacity(viewModel.selectedPeriod == .period ? 0.3 : 1.0)

                    Text(viewModel.dateRangeString)
                        .font(.headline)
                        .frame(minWidth: 120)
                        .onTapGesture {
                            if viewModel.selectedPeriod == .period {
                                showingDatePicker = true
                            }
                        }

                    Button(action: { viewModel.navigate(direction: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(viewModel.selectedPeriod == .period)
                    .opacity(viewModel.selectedPeriod == .period ? 0.3 : 1.0)

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
                    .onChange(of: viewModel.selectedPeriod) { period in
                        if period == .period {
                            showingDatePicker = true
                        }
                        viewModel.updateDateRange()
                    }
                }
                .padding()
                .sheet(isPresented: $showingDatePicker) {
                    StatsDateRangePickerView(startDate: $viewModel.customStartDate, endDate: $viewModel.customEndDate)
                        .onDisappear {
                            viewModel.updateDateRange()
                        }
                }

                // Income/Expense Summary Toggles
                HStack(spacing: 0) {
                    // Income Toggle
                    Button(action: {
                        viewModel.selectedType = .income
                        viewModel.fetchStats()
                    }) {
                        VStack(spacing: 8) {
                            Text("Income \(CurrencyFormatter.format(viewModel.totalIncome, currencySymbol: settings.currencySymbol))")
                                .fontWeight(viewModel.selectedType == .income ? .bold : .regular)
                                .foregroundColor(viewModel.selectedType == .income ? .primary : .secondary)
                            Rectangle()
                                .fill(viewModel.selectedType == .income ? Color.blue : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Expense Toggle
                    Button(action: {
                        viewModel.selectedType = .expense
                        viewModel.fetchStats()
                    }) {
                        VStack(spacing: 8) {
                            Text("Expenses \(CurrencyFormatter.format(viewModel.totalExpenses, currencySymbol: settings.currencySymbol))")
                                .fontWeight(viewModel.selectedType == .expense ? .bold : .regular)
                                .foregroundColor(viewModel.selectedType == .expense ? .primary : .secondary)
                            Rectangle()
                                .fill(viewModel.selectedType == .expense ? Color.red : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top)

                ScrollView {
                    if viewModel.stats.isEmpty {
                        EmptyStateView(
                            systemImage: "chart.pie",
                            title: "No data for this period",
                            message: "There are no \(viewModel.selectedType.title.lowercased())s recorded for the selected date range."
                        )
                        .padding(.top, 50)
                    } else {
                        VStack(spacing: 30) {
                            // --- CHART VIEW ---
                            VStack(spacing: 30) {
                                CategoryPieChartView(stats: viewModel.stats, selectedStatValue: $selectedStatValue)

                                // Detailed list of category statistics
                                VStack(spacing: 0) {
                                    ForEach(viewModel.stats) { stat in
                                        NavigationLink(destination: CategoryDetailView(category: stat.category)) {
                                            StatRow(stat: stat)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
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
