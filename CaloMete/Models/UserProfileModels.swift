import Foundation
import SwiftUI

// 性别枚举
enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "男性"
    case female = "女性"
    case other = "其他"
    
    var id: String { self.rawValue }
}

// 健身目标枚举
enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case lose = "减重"
    case maintain = "保持现状"
    case gain = "增重/增肌"
    
    var id: String { self.rawValue }
}

// 活动水平枚举
enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary = "久坐不动"
    case light = "轻度活动"
    case moderate = "中度活动"
    case active = "积极活动"
    case veryActive = "非常活跃"
    
    var id: String { self.rawValue }
    
    // 计算基础代谢率的活动系数
    var factor: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

// 饮食偏好枚举
enum DietaryPreference: String, Codable, CaseIterable, Identifiable {
    case normal = "普通饮食"
    case vegetarian = "素食"
    case vegan = "纯素"
    case pescatarian = "鱼素食"
    case glutenFree = "无麸质"
    case dairyFree = "无乳制品"
    case lowCarb = "低碳水"
    case highProtein = "高蛋白"
    
    var id: String { self.rawValue }
}

// 最近运动类型
enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case none = "无运动"
    case cardio = "有氧运动"
    case strength = "力量训练"
    case hiit = "高强度间歇训练"
    case yoga = "瑜伽"
    case flexibility = "柔韧性训练"
    
    var id: String { self.rawValue }
}

// 膳食记录
struct MealRecord: Identifiable, Codable {
    var id = UUID()
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var timestamp: Date
    
    // 膳食类型
    var type: MealType
    
    enum MealType: String, Codable, CaseIterable {
        case breakfast = "早餐"
        case lunch = "午餐"
        case dinner = "晚餐"
        case snack = "小食"
    }
}

// 营养建议模型
struct NutritionRecommendation {
    var title: String
    var calorieTarget: Double
    var proteinPercentage: Double
    var carbsPercentage: Double
    var fatPercentage: Double
    var specialNote: String = ""
    
    // 计算具体的宏量素建议
    var proteinGrams: Double {
        return (calorieTarget * proteinPercentage) / 4.0 // 蛋白质 4 卡路里/克
    }
    
    var carbsGrams: Double {
        return (calorieTarget * carbsPercentage) / 4.0 // 碳水 4 卡路里/克
    }
    
    var fatGrams: Double {
        return (calorieTarget * fatPercentage) / 9.0 // 脂肪 9 卡路里/克
    }
    
    // 生成膳食建议
    func generateMealSuggestions() -> [MealSuggestion] {
        var suggestions: [MealSuggestion] = []
        
        // 早餐 (25% 的总卡路里)
        let breakfastCalories = calorieTarget * 0.25
        var breakfastItems: [String] = []
        
        if carbsPercentage >= 0.4 {
            breakfastItems.append("全麦面包或燕麦粥")
        } else {
            breakfastItems.append("蛋白质奶昔或希腊酸奶")
        }
        
        if proteinPercentage >= 0.3 {
            breakfastItems.append("蛋白质来源（鸡蛋、豆腐或希腊酸奶）")
        }
        
        suggestions.append(MealSuggestion(
            type: .breakfast,
            calories: breakfastCalories,
            description: "早餐建议",
            foodItems: breakfastItems
        ))
        
        // 午餐 (35% 的总卡路里)
        let lunchCalories = calorieTarget * 0.35
        var lunchItems: [String] = []
        
        lunchItems.append("蛋白质来源（瘦肉、豆类或鱼）")
        
        if carbsPercentage >= 0.4 {
            lunchItems.append("全谷物或薯类")
        }
        
        lunchItems.append("蔬菜沙拉")
        
        suggestions.append(MealSuggestion(
            type: .lunch,
            calories: lunchCalories,
            description: "午餐建议",
            foodItems: lunchItems
        ))
        
        // 晚餐 (30% 的总卡路里)
        let dinnerCalories = calorieTarget * 0.3
        var dinnerItems: [String] = []
        
        dinnerItems.append("蛋白质来源（鱼、鸡肉或豆类）")
        
        if carbsPercentage < 0.4 {
            dinnerItems.append("低碳水蔬菜")
        } else {
            dinnerItems.append("适量全谷物")
            dinnerItems.append("蔬菜")
        }
        
        suggestions.append(MealSuggestion(
            type: .dinner,
            calories: dinnerCalories,
            description: "晚餐建议",
            foodItems: dinnerItems
        ))
        
        // 小食 (10% 的总卡路里)
        let snackCalories = calorieTarget * 0.1
        var snackItems: [String] = []
        
        if proteinPercentage >= 0.3 {
            snackItems.append("高蛋白零食（希腊酸奶、蛋白棒）")
        } else if fatPercentage >= 0.3 {
            snackItems.append("健康脂肪来源（坚果、牛油果）")
        } else {
            snackItems.append("水果和少量坚果")
        }
        
        suggestions.append(MealSuggestion(
            type: .snack,
            calories: snackCalories,
            description: "小食建议",
            foodItems: snackItems
        ))
        
        return suggestions
    }
}

// 膳食建议
struct MealSuggestion {
    var type: MealRecord.MealType
    var calories: Double
    var description: String
    var foodItems: [String]
}