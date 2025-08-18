//
//  AppDelegate.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import UIKit
import Network

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Application Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App entered background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("App will enter foreground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("App will terminate")
    }
}
