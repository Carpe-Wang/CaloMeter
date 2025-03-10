import Foundation
import SwiftUI
import HealthKit

public enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "男性"
    case female = "女性"
    case other = "其他"
    
    public var id: String { self.rawValue }
}

public enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case lose = "减重"
    case maintain = "保持现状"
    case gain = "增重/增肌"
    
    public var id: String { self.rawValue }
}

public enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary = "久坐不动"
    case light = "轻度活动"
    case moderate = "中度活动"
    case active = "积极活动"
    case veryActive = "非常活跃"
    
    public var id: String { self.rawValue }
    
    public var factor: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

public enum DietaryPreference: String, Codable, CaseIterable, Identifiable {
    case normal = "普通饮食"
    case vegetarian = "素食"
    case vegan = "纯素"
    case pescatarian = "鱼素食"
    case glutenFree = "无麸质"
    case dairyFree = "无乳制品"
    case lowCarb = "低碳水"
    case highProtein = "高蛋白"
    
    public var id: String { self.rawValue }
}

public enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case none = "无运动"
    case cardio = "有氧运动"
    case strength = "力量训练"
    case hiit = "高强度间歇训练"
    case yoga = "瑜伽"
    case flexibility = "柔韧性训练"
    
    public var id: String { self.rawValue }
}

public struct MealRecord: Identifiable, Codable {
    public var id = UUID()
    public var name: String
    public var calories: Double
    public var protein: Double
    public var carbs: Double
    public var fat: Double
    public var timestamp: Date
    public var type: MealType
    
    public enum MealType: String, Codable, CaseIterable {
        case breakfast = "早餐"
        case lunch = "午餐"
        case dinner = "晚餐"
        case snack = "小食"
    }
    
    public init(name: String, calories: Double, protein: Double, carbs: Double, fat: Double, timestamp: Date, type: MealType) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.timestamp = timestamp
        self.type = type
    }
}

public class UserProfileManager: ObservableObject {
    @Published public var weight: Double = 70.0 {
        didSet {
            saveProfile()
        }
    }
    @Published public var height: Double = 175.0 {
        didSet {
            saveProfile()
        }
    }
    @Published public var age: Int = 30 {
        didSet {
            saveProfile()
        }
    }
    @Published public var gender: Gender = .male {
        didSet {
            saveProfile()
        }
    }
    @Published public var fitnessGoal: FitnessGoal = .maintain {
        didSet {
            saveProfile()
        }
    }
    @Published public var activityLevel: ActivityLevel = .moderate {
        didSet {
            saveProfile()
        }
    }
    @Published public var dietaryPreference: DietaryPreference = .normal {
        didSet {
            saveProfile()
        }
    }
    @Published public var isProfileSetup: Bool = false {
        didSet {
            saveProfile()
        }
    }
    @Published public var recentWorkouts: [WorkoutType] = [.none] {
        didSet {
            saveProfile()
        }
    }
    @Published public var mealRecords: [MealRecord] = [] {
        didSet {
            saveProfile()
        }
    }
    
    public init() {
        loadProfile()
    }
    
    public func calculateBMR() -> Double {
        if gender == .male {
            return 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            return 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
    }
    
    public func calculateTDEE() -> Double {
        return calculateBMR() * activityLevel.factor
    }
    
    public func calculateCalorieTarget() -> Double {
        let tdee = calculateTDEE()
        
        switch fitnessGoal {
        case .lose:
            return tdee * 0.8
        case .maintain:
            return tdee
        case .gain:
            return tdee * 1.1
        }
    }
    
    public func addMealRecord(_ meal: MealRecord) {
        mealRecords.append(meal)
        saveProfile()
    }
    
    public func updateRecentWorkout(_ workoutType: WorkoutType) {
        if recentWorkouts.first != workoutType {
            recentWorkouts.insert(workoutType, at: 0)
            if recentWorkouts.count > 5 {
                recentWorkouts.removeLast()
            }
            saveProfile()
        }
    }
    
    public func generateNutritionRecommendation() -> NutritionRecommendation {
        var recommendation = NutritionRecommendation(
            title: "今日营养建议",
            calorieTarget: calculateCalorieTarget(),
            proteinPercentage: 0.25,
            carbsPercentage: 0.45, 
            fatPercentage: 0.3
        )
        
        if let recentWorkout = recentWorkouts.first {
            switch recentWorkout {
            case .strength:
                recommendation.title = "力量训练后的营养建议"
                recommendation.proteinPercentage = 0.35
                recommendation.carbsPercentage = 0.45
                recommendation.fatPercentage = 0.2
                recommendation.specialNote = "增加蛋白质摄入以支持肌肉恢复，配合快速吸收的碳水化合物"
                
            case .cardio:
                recommendation.title = "有氧运动后的营养建议"
                recommendation.proteinPercentage = 0.25
                recommendation.carbsPercentage = 0.55
                recommendation.fatPercentage = 0.2
                recommendation.specialNote = "补充碳水化合物，适量蛋白质帮助恢复"
                
            case .hiit:
                recommendation.title = "高强度间歇训练后的营养建议"
                recommendation.proteinPercentage = 0.3
                recommendation.carbsPercentage = 0.5
                recommendation.fatPercentage = 0.2
                recommendation.specialNote = "平衡的碳水和蛋白质摄入，支持肌肉恢复和能量补充"
                
            case .yoga, .flexibility:
                recommendation.title = "柔韧性训练后的营养建议"
                recommendation.proteinPercentage = 0.25
                recommendation.carbsPercentage = 0.5
                recommendation.fatPercentage = 0.25
                recommendation.specialNote = "均衡的营养摄入，注重抗炎食物"
                
            case .none:
                switch fitnessGoal {
                case .lose:
                    recommendation.title = "减重目标营养建议"
                    recommendation.proteinPercentage = 0.35
                    recommendation.carbsPercentage = 0.35
                    recommendation.fatPercentage = 0.3
                    recommendation.specialNote = "提高蛋白质摄入，控制碳水摄入量，避免晚上摄入过多碳水"
                    
                case .gain:
                    recommendation.title = "增肌目标营养建议"
                    recommendation.proteinPercentage = 0.3
                    recommendation.carbsPercentage = 0.5
                    recommendation.fatPercentage = 0.2
                    recommendation.specialNote = "适量增加总热量摄入，保证足够的蛋白质和碳水化合物"
                    
                case .maintain:
                    recommendation.title = "维持体重营养建议"
                    recommendation.specialNote = "保持均衡饮食，注意食物多样性"
                }
            }
        }
        
        switch dietaryPreference {
        case .vegetarian, .vegan:
            recommendation.specialNote += "。建议摄入多种植物蛋白质来源，如豆制品、藜麦、坚果等"
        case .highProtein:
            recommendation.proteinPercentage += 0.05
            recommendation.carbsPercentage -= 0.05
        case .lowCarb:
            recommendation.carbsPercentage -= 0.1
            recommendation.fatPercentage += 0.05
            recommendation.proteinPercentage += 0.05
        default:
            break
        }
        
        return recommendation
    }
    
    public func saveProfile() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserProfile")
        }
    }
    
    public func loadProfile() {
        if let savedProfile = UserDefaults.standard.data(forKey: "UserProfile"),
           let loadedProfile = try? JSONDecoder().decode(UserProfileManager.self, from: savedProfile) {
            self.weight = loadedProfile.weight
            self.height = loadedProfile.height
            self.age = loadedProfile.age
            self.gender = loadedProfile.gender
            self.fitnessGoal = loadedProfile.fitnessGoal
            self.activityLevel = loadedProfile.activityLevel
            self.dietaryPreference = loadedProfile.dietaryPreference
            self.isProfileSetup = loadedProfile.isProfileSetup
            self.recentWorkouts = loadedProfile.recentWorkouts
            self.mealRecords = loadedProfile.mealRecords
        }
    }
}

public struct NutritionRecommendation {
    public var title: String
    public var calorieTarget: Double
    public var proteinPercentage: Double
    public var carbsPercentage: Double
    public var fatPercentage: Double
    public var specialNote: String = ""
    
    public var proteinGrams: Double {
        return (calorieTarget * proteinPercentage) / 4.0
    }
    
    public var carbsGrams: Double {
        return (calorieTarget * carbsPercentage) / 4.0
    }
    
    public var fatGrams: Double {
        return (calorieTarget * fatPercentage) / 9.0
    }
    
    public func generateMealSuggestions() -> [MealSuggestion] {
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
    
    public init(title: String, calorieTarget: Double, proteinPercentage: Double, carbsPercentage: Double, fatPercentage: Double, specialNote: String = "") {
        self.title = title
        self.calorieTarget = calorieTarget
        self.proteinPercentage = proteinPercentage
        self.carbsPercentage = carbsPercentage
        self.fatPercentage = fatPercentage
        self.specialNote = specialNote
    }
}

public struct MealSuggestion {
    public var type: MealRecord.MealType
    public var calories: Double
    public var description: String
    public var foodItems: [String]
    
    public init(type: MealRecord.MealType, calories: Double, description: String, foodItems: [String]) {
        self.type = type
        self.calories = calories
        self.description = description
        self.foodItems = foodItems
    }
}

extension UserProfileManager: Codable {
    enum CodingKeys: String, CodingKey {
        case weight, height, age, gender, fitnessGoal, activityLevel, dietaryPreference, isProfileSetup, recentWorkouts, mealRecords
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(weight, forKey: .weight)
        try container.encode(height, forKey: .height)
        try container.encode(age, forKey: .age)
        try container.encode(gender, forKey: .gender)
        try container.encode(fitnessGoal, forKey: .fitnessGoal)
        try container.encode(activityLevel, forKey: .activityLevel)
        try container.encode(dietaryPreference, forKey: .dietaryPreference)
        try container.encode(isProfileSetup, forKey: .isProfileSetup)
        try container.encode(recentWorkouts, forKey: .recentWorkouts)
        try container.encode(mealRecords, forKey: .mealRecords)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weight = try container.decode(Double.self, forKey: .weight)
        height = try container.decode(Double.self, forKey: .height)
        age = try container.decode(Int.self, forKey: .age)
        gender = try container.decode(Gender.self, forKey: .gender)
        fitnessGoal = try container.decode(FitnessGoal.self, forKey: .fitnessGoal)
        activityLevel = try container.decode(ActivityLevel.self, forKey: .activityLevel)
        dietaryPreference = try container.decode(DietaryPreference.self, forKey: .dietaryPreference)
        isProfileSetup = try container.decode(Bool.self, forKey: .isProfileSetup)
        recentWorkouts = try container.decodeIfPresent([WorkoutType].self, forKey: .recentWorkouts) ?? [.none]
        mealRecords = try container.decodeIfPresent([MealRecord].self, forKey: .mealRecords) ?? []
    }
}