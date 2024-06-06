//
//  ContentView.swift
//  CaloMete
//
//  Created by CarpeWang on 2024/6/6.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var basalCalories: Double = 0
    @State private var activeCalories: Double = 0
    @State private var totalCalories: Double = 0

    var body: some View {
        VStack {
            Text("Basal Calories: \(basalCalories, specifier: "%.2f") kcal")
            Text("Active Calories: \(activeCalories, specifier: "%.2f") kcal")
            Text("Total Calories: \(totalCalories, specifier: "%.2f") kcal")
        }
        .onAppear {
            healthKitManager.fetchBasalEnergyBurned { basalCalories, error in
                if let error = error {
                    print("Error fetching basal energy: \(error.localizedDescription)")
                    return
                }
                self.basalCalories = basalCalories
                healthKitManager.fetchActiveEnergyBurned { activeCalories, error in
                    if let error = error {
                        print("Error fetching active energy: \(error.localizedDescription)")
                        return
                    }
                    self.activeCalories = activeCalories
                    self.totalCalories = basalCalories + activeCalories
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(HealthKitManager())
    }
}
