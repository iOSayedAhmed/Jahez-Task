//
//  Jahez_TaskApp.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 18/08/2025.
//

import SwiftUI

@main
struct Jahez_TaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(NetworkMonitor.shared)
        }
    }
}
