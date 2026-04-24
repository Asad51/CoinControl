//
//  CategoryPieChartView.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import Charts
import SwiftUI

/// A view that displays a pie chart of category statistics.
/// It uses SwiftUI Charts (SectorMark) for iOS 17+ and a custom Path-based fallback for iOS 16.
struct CategoryPieChartView: View {
    let stats: [CategoryStat]

    /// The value captured from chartAngleSelection. This represents the cumulative value
    /// at the angle the user is touching.
    @Binding var selectedStatValue: Double?

    /// Computed property to find the specific CategoryStat being selected.
    private var selectedStat: CategoryStat? {
        guard let value = selectedStatValue else { return nil }
        var cumulative = 0.0
        for stat in stats {
            cumulative += stat.amount
            if value <= cumulative {
                return stat
            }
        }
        return nil
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            // Modern Pie Chart using SectorMark (iOS 17+)
            Chart(stats) { stat in
                let isSelected = selectedStat?.id == stat.id

                SectorMark(
                    angle: .value("Amount", stat.amount),
                    // If this sector is selected, shrink the inner radius to create a donut-like pop-out
                    innerRadius: isSelected ? .ratio(0.2) : .ratio(0),
                    // Elevate the selected sector by making it slightly larger than the others
                    outerRadius: isSelected ? .ratio(1.0) : .ratio(0.9),
                    // Add some spacing around the selected sector
                    angularInset: isSelected ? 4 : 1
                )
                .foregroundStyle(stat.color)
                .annotation(position: .overlay) {
                    if isSelected {
                        // Detailed label for the selected slice
                        VStack {
                            Text(stat.category.name)
                                .font(.caption2).bold()
                            Text("\(Int(stat.percentage))%")
                                .font(.system(size: 8))
                        }
                        .padding(4)
                        .background(Color(UIColor.systemBackground).opacity(0.9))
                        .cornerRadius(4)
                    } else if stat.percentage > 5 {
                        // Simple inside label for larger slices when not selected
                        VStack {
                            Text(stat.category.name)
                                .font(.caption2)
                            Text("\(Int(stat.percentage))%")
                                .font(.caption2).bold()
                        }
                    }
                }
            }
            .chartAngleSelection(value: $selectedStatValue)
            .animation(.spring(), value: selectedStatValue)
            .frame(height: 300)
            .padding(.top)
        } else {
            // Custom fallback for iOS 16 where SectorMark is unavailable
            PieChartFallback(stats: stats)
                .frame(height: 300)
                .padding(.top)
        }
    }
}

/// A simple Path-based pie chart for iOS 16 compatibility.
struct PieChartFallback: View {
    let stats: [CategoryStat]

    var body: some View {
        ZStack {
            ForEach(0 ..< stats.count, id: \.self) { index in
                PieSlice(startAngle: startAngle(for: index), endAngle: endAngle(for: index))
                    .fill(stats[index].color)
            }
        }
    }

    private func startAngle(for index: Int) -> Angle {
        let prevSum = stats.prefix(index).reduce(0) { $0 + $1.amount }
        let total = stats.reduce(0) { $0 + $1.amount }
        return .degrees(prevSum / total * 360 - 90)
    }

    private func endAngle(for index: Int) -> Angle {
        let currentSum = stats.prefix(index + 1).reduce(0) { $0 + $1.amount }
        let total = stats.reduce(0) { $0 + $1.amount }
        return .degrees(currentSum / total * 360 - 90)
    }
}

/// A custom Shape for drawing an individual slice of the pie chart.
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
