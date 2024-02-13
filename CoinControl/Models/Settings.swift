//
//  Settings.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 14/2/24.
//

import Foundation
import SwiftUI

/// This class contains the settings of the application
class Settings: ObservableObject {
    /// Tint color selected by the user
    @Published var accentColor: Color = .tintBlue
}
