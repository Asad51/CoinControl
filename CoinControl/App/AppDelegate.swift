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
        AppCenter.start(withAppSecret: "d372f15d-68c7-4adf-88fc-a90c644b4d35", services: [
            Crashes.self, Analytics.self])
        return true
    }
}
