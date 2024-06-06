//
//  CaloMeteApp.swift
//  CaloMete WatchKit Extension
//
//  Created by CarpeWang on 2024/6/6.
//

import SwiftUI

@main
struct CaloMeteApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
