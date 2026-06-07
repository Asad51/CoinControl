//
//  Settings.swift
//  CoinControl
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("currencySymbol") var currencySymbol: String = "৳"
    
    // We'll keep accentColor as @Published for now as in the original, 
    // but the task is to add onboarding and currency.
    @Published var accentColor: Color = .tintBlue
}
