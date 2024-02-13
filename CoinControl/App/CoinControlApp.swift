//
//  CoinControlApp.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 25/1/24.
//

import SwiftUI

@main
struct CoinControlApp: App {
    @StateObject private var settings = Settings()

    init() {
        CCLogger.initialize()

        CCLogger.info("Launching application...")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
        }
    }
}
