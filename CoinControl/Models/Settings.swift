//
//  Settings.swift
//  CoinControl
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("currencySymbol") var currencySymbol: String = "৳"
    @AppStorage("accentColorName") private var accentColorName: String = "Blue"

    var accentColor: Color {
        get {
            switch accentColorName {
                case "Blue": return .tintBlue
                case "Green": return .tintGreen
                case "Navy": return .tintNavy
                case "Orange": return .tintOrange
                case "Pink": return .tintPink
                case "Violet": return .tintViolet
                default: return .tintBlue
            }
        }
        set {
            /// This is a bit hacky since we can't easily map back from Color to Name
            /// without a mapping. For now, we'll let the view set the name directly
            /// or we could add a method.
        }
    }

    func setAccentColor(name: String) {
        accentColorName = name
        objectWillChange.send()
    }

    func isSelected(colorName: String) -> Bool {
        accentColorName == colorName
    }
}
