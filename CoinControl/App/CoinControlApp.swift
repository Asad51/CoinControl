//
//  CoinControlApp.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 25/1/24.
//

import CoreData
import SwiftUI

@main
struct CoinControlApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var settings = Settings()

    init() {
        CCLogger.initialize()
        CCLogger.info("Launching application...")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }
}
