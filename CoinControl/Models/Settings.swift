//
//  Settings.swift
//  CoinControl
//

import Combine
import Foundation
import SwiftUI

class Settings: ObservableObject {
    static let availableAccentColors: [(String, Color)] = [
        ("Blue", .tintBlue),
        ("Green", .tintGreen),
        ("Navy", .tintNavy),
        ("Orange", .tintOrange),
        ("Pink", .tintPink),
        ("Violet", .tintViolet),
    ]

    @Published var hasCompletedOnboarding: Bool {
        didSet { userDefaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    @Published var currencySymbol: String {
        didSet { userDefaults.set(currencySymbol, forKey: Keys.currencySymbol) }
    }

    @Published private(set) var accentColorName: String {
        didSet { userDefaults.set(accentColorName, forKey: Keys.accentColorName) }
    }

    var accentColor: Color {
        get {
            Settings.availableAccentColors.first { $0.0 == accentColorName }?.1 ?? .tintBlue
        }
        set {
            guard let name = Settings.availableAccentColors.first(where: { $0.1 == newValue })?.0 else {
                assertionFailure("Unknown accent color: \(newValue)")
                return
            }
            setAccentColor(name: name)
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        hasCompletedOnboarding = userDefaults.bool(forKey: Keys.hasCompletedOnboarding)
        currencySymbol = userDefaults.string(forKey: Keys.currencySymbol) ?? "৳"
        accentColorName = userDefaults.string(forKey: Keys.accentColorName) ?? "Blue"
    }

    func setAccentColor(name: String) {
        accentColorName = name
    }

    func isSelected(colorName: String) -> Bool {
        accentColorName == colorName
    }

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let currencySymbol = "currencySymbol"
        static let accentColorName = "accentColorName"
    }
}
