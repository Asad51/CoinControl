//
//  TransactionHeaderView.swift
//  CoinControl
//

import SwiftUI

struct TransactionHeaderView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @Binding var selectedTopTab: TransactionTopTab
    @Namespace private var animation
    let topTabs = TransactionTopTab.allCases

    var body: some View {
        VStack(spacing: 0) {
            // Month/Year Navigation and Action Icons
            HStack {
                if viewModel.isSearching {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search by title...", text: $viewModel.searchQuery)
                            .textFieldStyle(PlainTextFieldStyle())

                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button("Cancel") {
                            withAnimation {
                                viewModel.isSearching = false
                                viewModel.searchQuery = ""
                            }
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    Button(action: {
                        if selectedTopTab == .monthly {
                            viewModel.previousYear()
                        } else {
                            viewModel.previousMonth()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                    }

                    Text(selectedTopTab == .monthly ? viewModel.selectedYear : viewModel.selectedMonthYear)
                        .font(.headline)
                        .frame(minWidth: 100)
                        .padding(.horizontal, 8)

                    Button(action: {
                        if selectedTopTab == .monthly {
                            viewModel.nextYear()
                        } else {
                            viewModel.nextMonth()
                        }
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    Spacer()

                    HStack(spacing: 20) {
                        Button(action: {
                            withAnimation {
                                viewModel.isSearching = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
            }
            .padding()
            .foregroundColor(.primary)

            if !viewModel.isSearching {
                // Top Tabs
                HStack(spacing: 0) {
                    ForEach(topTabs, id: \.self) { tab in
                        VStack(spacing: 8) {
                            Text(tab.title)
                                .font(.subheadline)
                                .fontWeight(selectedTopTab == tab ? .bold : .regular)
                                .foregroundColor(selectedTopTab == tab ? .primary : .secondary)

                            ZStack {
                                if selectedTopTab == tab {
                                    Rectangle()
                                        .fill(Color.red.opacity(0.8))
                                        .frame(height: 3)
                                        .matchedGeometryEffect(id: "TabIndicator", in: animation)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 3)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTopTab = tab
                            }
                        }
                    }
                }
                .padding(.top, 8)

                // Summary View
                HStack {
                    SummaryItemView(
                        title: "Income",
                        amount: selectedTopTab == .monthly ? viewModel.totalIncome : viewModel.monthlyIncome,
                        color: .blue
                    )
                    Spacer()
                    SummaryItemView(
                        title: "Expenses",
                        amount: selectedTopTab == .monthly ? viewModel.totalExpenses : viewModel.monthlyExpenses,
                        color: .red
                    )
                    Spacer()
                    SummaryItemView(
                        title: "Total",
                        amount: selectedTopTab == .monthly ? viewModel.totalBalance : viewModel.monthlyBalance,
                        color: .primary
                    )
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .background(Color(UIColor.systemBackground)) // Adapts to system theme
    }
}

struct SummaryItemView: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f", amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#if DEBUG
    #Preview {
        TransactionHeaderView(viewModel: TransactionsViewModel(), selectedTopTab: .constant(.daily))
            .background(Color(UIColor.systemBackground))
    }
#endif
