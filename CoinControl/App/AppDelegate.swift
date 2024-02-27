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
        AppCenter.start(withAppSecret: "16274a8c-9ae2-46e1-a145-5724eeb2320c", services: [
            Crashes.self, Analytics.self])
        return true
    }
}
