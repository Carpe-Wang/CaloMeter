import Foundation
import SwiftUI

// 用户资料管理类
class UserProfileManager: ObservableObject {
    // 发布属性，当这些属性改变时会通知观察者
    @Published var weight: Double = 70.0 {
        didSet {
            saveProfile()
        }
    }
    @Published var height: Double = 175.0 {
        didSet {
            saveProfile()
        }
    }
    @Published var age: Int = 30 {
        didSet {
            saveProfile()
        }
    }
    @Published var gender: Gender = .male {
        didSet {
            saveProfile()
        }
    }
    @Published var fitnessGoal: FitnessGoal = .maintain {
        didSet {
            saveProfile()
        }
    }
    @Published var activityLevel: ActivityLevel = .moderate {
        didSet {
            saveProfile()
        }
    }
    @Published var dietaryPreference: DietaryPreference = .normal {
        didSet {
            saveProfile()
        }
    }
    @Published var isProfileSetup: Bool = false {
        didSet {
            saveProfile()
        }
    }
    @Published var recentWorkouts: [WorkoutType] = [.none] {
        didSet {
            saveProfile()
        }
    }
    @Published var mealRecords: [MealRecord] = [] {
        didSet {
            saveProfile()
        }
    }
    
    init() {
        loadProfile()
    }
    
    // 计算基础代谢率 (BMR)
    func calculateBMR() -> Double {
        // 使用 Mifflin-St Jeor 公式计算 BMR
        // 男性: BMR = 10 × 体重(kg) + 6.25 × 身高(cm) - 5 × 年龄(y) + 5
        // 女性: BMR = 10 × 体重(kg) + 6.25 × 身高(cm) - 5 × 年龄(y) - 161
        
        if gender == .male {
            return 10 * weight + 6.25 * height - 5 * Double(age) + 5
        } else {
            return 10 * weight + 6.25 * height - 5 * Double(age) - 161
        }
    }
    
    // 计算每日总能量消耗 (TDEE)
    func calculateTDEE() -> Double {
        // 根据活动水平计算 TDEE
        return calculateBMR() * activityLevel.factor
    }
    
    // 计算推荐的每日卡路里摄入量
    func calculateCalorieTarget() -> Double {
        let tdee = calculateTDEE()
        
        switch fitnessGoal {
        case .lose:
            return tdee * 0.8 // 减少 20% 卡路里摄入促进减重
        case .maintain:
            return tdee
        case .gain:
            return tdee * 1.1 // 增加 10% 卡路里摄入促进增重/增肌
        }
    }
    
    // 添加膳食记录
    func addMealRecord(_ meal: MealRecord) {
        mealRecords.append(meal)
        saveProfile()
    }
    
    // 更新最近运动类型
    func updateRecentWorkout(_ workoutType: WorkoutType) {
        if recentWorkouts.first != workoutType {
            recentWorkouts.insert(workoutType, at: 0)
            if recentWorkouts.count > 5 {
                recentWorkouts.removeLast()
            }
            saveProfile()
        }
    }
    
    // 根据最近的运动类型生成营养建议
    func generateNutritionRecommendation() -> NutritionRecommendation {
        var recommendation = NutritionRecommendation(
            title: "今日营养建议",
            calorieTarget: calculateCalorieTarget(),
            proteinPercentage: 0.25,
            carbsPercentage: 0.45, 
            fatPercentage: 0.3
        )
        
        // 根据最近的运动调整营养建议
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
                // 根据健身目标调整默认建议
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
        
        // 根据饮食偏好调整建议
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
    
    // 保存用户配置文件
    func saveProfile() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserProfile")
        }
    }
    
    // 加载用户配置文件
    func loadProfile() {
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

// 使 UserProfileManager 符合 Codable 协议，以便保存和加载
extension UserProfileManager: Codable {
    enum CodingKeys: String, CodingKey {
        case weight, height, age, gender, fitnessGoal, activityLevel, dietaryPreference, isProfileSetup, recentWorkouts, mealRecords
    }
    
    func encode(to encoder: Encoder) throws {
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
    
    required init(from decoder: Decoder) throws {
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
    
    init() {
        // 默认初始化已在类定义中完成
    }
}