//
//  AppDelegate.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 28/2/24.
//

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        AppCenter.start(withAppSecret: "41711e8d-cbcd-4d45-b905-3115c2f813ed", services: [
            Crashes.self, Analytics.self])
        return true
    }
}
