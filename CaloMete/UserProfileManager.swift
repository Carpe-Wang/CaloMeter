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
        }
    }
}

// 使 UserProfileManager 符合 Codable 协议，以便保存和加载
extension UserProfileManager: Codable {
    enum CodingKeys: String, CodingKey {
        case weight, height, age, gender, fitnessGoal, activityLevel, dietaryPreference, isProfileSetup
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
    }
    
    init() {
        // 默认初始化已在类定义中完成
    }
}
