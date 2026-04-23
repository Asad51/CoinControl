//
//  StatsPeriod.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 23/4/26.
//

import Foundation

enum StatsPeriod: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case annually = "Annually"
    case period = "Period"

    var id: String {
        rawValue
    }
}
