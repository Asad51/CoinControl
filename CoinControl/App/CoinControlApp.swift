//
//  CoinControlApp.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 25/1/24.
//

import SwiftUI

@main
struct CoinControlApp: App {
    init() {
        CCLogger.initialize()

        CCLogger.info("Launching application...")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
