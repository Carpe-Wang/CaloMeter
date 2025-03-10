//
//  CaloMeteApp.swift
//  CaloMete WatchKit Extension
//
//  Created by CarpeWang on 2024/6/6.
//

import SwiftUI
import HealthKit

@main
struct CaloMeteApp: App {
    // 创建 HealthKitManager, UserProfileManager 和 NutritionAIService 实例
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var nutritionAIService = NutritionAIService()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                // 根据用户是否已设置个人资料决定显示哪个视图
                if userProfileManager.isProfileSetup {
                    ContentView()
                        .environmentObject(healthKitManager)
                        .environmentObject(userProfileManager)
                        .environmentObject(nutritionAIService)
                        .onAppear {
                            // 应用出现时刷新健康数据
                            healthKitManager.fetchHealthData()
                            // 生成新的膳食推荐
                            nutritionAIService.generateRecommendations(
                                userProfile: userProfileManager,
                                healthData: healthKitManager
                            )
                        }
                } else {
                    OnboardingView()
                        .environmentObject(userProfileManager)
                        .environmentObject(healthKitManager)
                }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
