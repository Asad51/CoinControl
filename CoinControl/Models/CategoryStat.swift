//
//  CategoryStat.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import SwiftUI

struct CategoryStat: Identifiable, Equatable {
    let id = UUID()
    let category: Category
    let amount: Double
    let percentage: Double
    let color: Color
}
