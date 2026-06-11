//
//  ExportOptionsView.swift
//  CoinControl
//

import SwiftUI

struct ExportOptionsView: View {
    @Binding var isPresented: Bool
    let onSelect: (ExportPeriod) -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            // Explicitly NOT adding onTapGesture to prevent dismissal by tapping outside

            VStack(spacing: 0) {
                // Header with Title and Close Button
                HStack {
                    Text("Export to Excel")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                }
                .padding()

                Text("Select a period to export transactions.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                // Options List
                VStack(spacing: 0) {
                    ForEach(ExportPeriod.allCases) { period in
                        Button(action: {
                            onSelect(period)
                            isPresented = false
                        }) {
                            HStack {
                                Text(period.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .contentShape(Rectangle())
                        }

                        if period != ExportPeriod.allCases.last {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .padding(.horizontal, 30)
            .shadow(color: .black.opacity(0.2), radius: 20)
        }
    }
}

#Preview {
    ExportOptionsView(isPresented: .constant(true)) { _ in }
}
