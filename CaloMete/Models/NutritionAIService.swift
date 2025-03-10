import Foundation
import SwiftUI

// 简单的 AI 膳食推荐服务
class NutritionAIService: ObservableObject {
    @Published var currentRecommendation: NutritionRecommendation?
    @Published var mealSuggestions: [MealSuggestion] = []
    @Published var isLoading: Bool = false
    
    // 根据用户资料和健康数据生成膳食推荐
    func generateRecommendations(userProfile: UserProfileManager, healthData: HealthKitManager) {
        isLoading = true
        
        // 模拟 AI 处理延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 首先从用户资料获取基础推荐
            let recommendation = userProfile.generateNutritionRecommendation()
            
            // 如果有最近的运动记录，将其更新到用户资料中
            if let recentWorkout = healthData.recentWorkouts.first {
                let workoutType = healthData.mapHKWorkoutToAppWorkoutType(recentWorkout)
                userProfile.updateRecentWorkout(workoutType)
                
                // 重新生成考虑了最新运动的推荐
                let updatedRecommendation = userProfile.generateNutritionRecommendation()
                self.currentRecommendation = updatedRecommendation
                self.mealSuggestions = updatedRecommendation.generateMealSuggestions()
            } else {
                self.currentRecommendation = recommendation
                self.mealSuggestions = recommendation.generateMealSuggestions()
            }
            
            self.isLoading = false
        }
    }
    
    // 针对特定时间生成膳食建议
    func getMealForCurrentTime() -> MealSuggestion? {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // 根据当前时间返回相应的膳食建议
        if hour < 10 {
            // 早餐 (5:00 - 10:00)
            return mealSuggestions.first { $0.type == .breakfast }
        } else if hour < 14 {
            // 午餐 (10:00 - 14:00)
            return mealSuggestions.first { $0.type == .lunch }
        } else if hour < 19 {
            // 晚餐 (14:00 - 19:00)
            return mealSuggestions.first { $0.type == .dinner }
        } else {
            // 小食 (其他时间)
            return mealSuggestions.first { $0.type == .snack }
        }
    }
}