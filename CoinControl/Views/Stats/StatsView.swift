//
//  StatsView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import Charts
import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var selectedStatValue: Double? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header navigation
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

                    // Period Picker (Dropdown style)
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

                // Income/Expense Toggles
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
                        // --- SWIFT CHARTS PIE CHART ---
                        if #available(iOS 17.0, *) {
                            Chart(viewModel.stats) { stat in
                                SectorMark(
                                    angle: .value("Amount", stat.amount),
                                    innerRadius: selectedStatValue == stat.amount ? 0.4 : 0,
                                    angularInset: selectedStatValue == stat.amount ? 4 : 1
                                )
                                .foregroundStyle(stat.color)
                                .annotation(position: .overlay) {
                                    if stat.percentage > 5 {
                                        VStack {
                                            Text(stat.category.name)
                                                .font(.caption2)
                                            Text("\(Int(stat.percentage))%")
                                                .font(.caption2).bold()
                                        }
                                        .padding(4)
                                        .background(Color(UIColor.systemBackground).opacity(0.8))
                                        .cornerRadius(4)
                                    }
                                }
                            }
                            .chartAngleSelection(value: $selectedStatValue)
                            .frame(height: 300)
                            .padding(.top)
                        } else {
                            // Fallback for iOS versions earlier than 17.0 where SectorMark isn't available
                            VStack(spacing: 8) {
                                Image(systemName: "chart.pie")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("Category breakdown requires iOS 17")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 300)
                            .padding(.top)
                        }

                        // --- STATS LIST ---
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
