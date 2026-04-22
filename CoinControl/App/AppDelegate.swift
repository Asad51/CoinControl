//
//  AppDelegate.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 28/2/24.
//

import Firebase
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
