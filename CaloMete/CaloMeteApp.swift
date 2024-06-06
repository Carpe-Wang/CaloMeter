//
//  CaloMeteApp.swift
//  CaloMete
//
//  Created by CarpeWang on 2024/6/6.
//
import SwiftUI

@main
struct CaloMeteApp: App {
    @StateObject private var healthKitManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
                .onAppear {
                    healthKitManager.requestAuthorization { success, error in
                        if success {
                            print("HealthKit authorization granted.")
                        } else {
                            print("HealthKit authorization denied. \(String(describing: error?.localizedDescription))")
                        }
                    }
                }
        }
    }
}
