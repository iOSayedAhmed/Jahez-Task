//
//  Jahez-Task.swift
//  Jahez-Task
//
//  Created by Elsayed Ahmed on 19/08/2025.
//

import SwiftUI

@main
struct Jahez_Task: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showSplash = true

       var body: some Scene {
           WindowGroup {
               if showSplash {
                   SplashView {
                       showSplash = false
                   }
               } else {
                   CoordinatorView()
               }
           }
       }
}
