//
//  ContentView.swift
//  CaloMete WatchKit Extension
//
//  Created by CarpeWang on 2024/6/6.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var nutritionAIService: NutritionAIService
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 卡路里和健康数据视图
            CaloriesView()
                .tag(0)
            
            // 今日建议视图
            RecommendationsView()
                .tag(1)
            
            // 膳食记录视图
            MealLogView()
                .tag(2)
            
            // 个人资料视图
            ProfileView()
                .tag(3)
        }
        .onAppear {
            // 每次出现时刷新数据
            healthKitManager.fetchHealthData()
            nutritionAIService.generateRecommendations(
                userProfile: userProfileManager, 
                healthData: healthKitManager
            )
        }
    }
}

// 卡路里和健康数据视图
struct CaloriesView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("今日热量")
                    .font(.headline)
                
                // 卡路里环形进度
                ZStack {
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)
                    
                    let totalCalories = healthKitManager.restingCalories + healthKitManager.activeCalories
                    let targetCalories = userProfileManager.calculateCalorieTarget()
                    let progress = min(totalCalories / targetCalories, 1.0)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: progress)
                    
                    VStack {
                        Text("\(Int(totalCalories))")
                            .font(.system(size: 24, weight: .bold))
                        Text("/ \(Int(targetCalories))")
                            .font(.caption2)
                        Text("千卡")
                            .font(.caption)
                    }
                }
                .frame(width: 130, height: 130)
                .padding(.vertical, 10)
                
                Divider()
                
                // 静息和活动卡路里详情
                HStack {
                    VStack(alignment: .leading) {
                        Text("静息热量")
                            .font(.caption)
                        Text("\(Int(healthKitManager.restingCalories))")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("活动热量")
                            .font(.caption)
                        Text("\(Int(healthKitManager.activeCalories))")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
                
                // 步数
                HStack {
                    Image(systemName: "figure.walk")
                    Text("\(healthKitManager.steps) 步")
                        .font(.body)
                }
                .padding(.top, 5)
                
                // 刷新按钮
                Button(action: {
                    healthKitManager.fetchHealthData()
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .buttonStyle(BorderedButtonStyle(tint: .blue))
                .padding(.top, 5)
            }
            .padding()
        }
    }
}

// 饮食建议视图
struct RecommendationsView: View {
    @EnvironmentObject var nutritionAIService: NutritionAIService
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if nutritionAIService.isLoading {
                    ProgressView()
                        .padding()
                    Text("生成建议中...")
                        .font(.caption)
                } else if let recommendation = nutritionAIService.currentRecommendation {
                    // 显示当前时段的膳食建议
                    if let currentMeal = nutritionAIService.getMealForCurrentTime() {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("当前推荐")
                                .font(.headline)
                            
                            Text(currentMeal.type.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(currentMeal.foodItems, id: \.self) { item in
                                Label(item, systemImage: "checkmark.circle")
                                    .font(.caption)
                                    .padding(.vertical, 2)
                            }
                            
                            Text("\(Int(currentMeal.calories)) 千卡")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Divider()
                    
                    // 营养摄入建议
                    VStack(alignment: .leading, spacing: 5) {
                        Text(recommendation.title)
                            .font(.headline)
                        
                        if !recommendation.specialNote.isEmpty {
                            Text(recommendation.specialNote)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 5)
                        }
                        
                        HStack {
                            MacronutrientView(
                                name: "蛋白质",
                                value: Int(recommendation.proteinGrams),
                                percentage: recommendation.proteinPercentage,
                                color: .red
                            )
                            
                            MacronutrientView(
                                name: "碳水",
                                value: Int(recommendation.carbsGrams),
                                percentage: recommendation.carbsPercentage,
                                color: .blue
                            )
                            
                            MacronutrientView(
                                name: "脂肪",
                                value: Int(recommendation.fatGrams),
                                percentage: recommendation.fatPercentage,
                                color: .yellow
                            )
                        }
                    }
                    .padding()
                    
                    // 所有膳食建议
                    VStack(alignment: .leading, spacing: 10) {
                        Text("今日膳食计划")
                            .font(.headline)
                        
                        ForEach(nutritionAIService.mealSuggestions, id: \.description) { meal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(meal.type.rawValue)
                                        .font(.subheadline)
                                    Text("\(Int(meal.calories)) 千卡")
                                        .font(.caption)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                    
                    // 刷新按钮
                    Button(action: {
                        nutritionAIService.generateRecommendations(
                            userProfile: userProfileManager,
                            healthData: HealthKitManager()
                        )
                    }) {
                        Label("刷新建议", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(BorderedButtonStyle(tint: .blue))
                } else {
                    Text("未能生成建议")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        nutritionAIService.generateRecommendations(
                            userProfile: userProfileManager,
                            healthData: HealthKitManager()
                        )
                    }) {
                        Label("重试", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(BorderedButtonStyle(tint: .blue))
                }
            }
            .padding()
        }
    }
}

// 宏营养素视图
struct MacronutrientView: View {
    var name: String
    var value: Int
    var percentage: Double
    var color: Color
    
    var body: some View {
        VStack {
            Text(name)
                .font(.caption2)
            
            Text("\(value)g")
                .font(.caption)
                .bold()
            
            Text("\(Int(percentage * 100))%")
                .font(.caption2)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// 膳食记录视图
struct MealLogView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var showingAddMeal = false
    @State private var newMeal = MealRecord(
        name: "",
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        timestamp: Date(),
        type: .lunch
    )
    
    var body: some View {
        VStack {
            if userProfileManager.mealRecords.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("还没有记录膳食")
                        .font(.headline)
                    
                    Text("点击下方按钮添加")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                
                Spacer()
            } else {
                List {
                    ForEach(userProfileManager.mealRecords.sorted(by: { $0.timestamp > $1.timestamp })) { meal in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(meal.name)
                                    .font(.headline)
                                Spacer()
                                Text(meal.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("\(Int(meal.calories)) 千卡")
                                .font(.subheadline)
                            
                            HStack {
                                Text("蛋白质: \(Int(meal.protein))g")
                                    .font(.caption)
                                
                                Text("碳水: \(Int(meal.carbs))g")
                                    .font(.caption)
                                
                                Text("脂肪: \(Int(meal.fat))g")
                                    .font(.caption)
                            }
                            
                            Text(meal.timestamp, style: .date)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            
            Button(action: {
                showingAddMeal = true
            }) {
                Label("添加膳食", systemImage: "plus")
            }
            .buttonStyle(BorderedButtonStyle(tint: .green))
            .padding(.bottom, 5)
        }
        .sheet(isPresented: $showingAddMeal) {
            AddMealView(meal: $newMeal) { meal in
                userProfileManager.addMealRecord(meal)
                // 重置新膳食
                newMeal = MealRecord(
                    name: "",
                    calories: 0,
                    protein: 0,
                    carbs: 0,
                    fat: 0,
                    timestamp: Date(),
                    type: .lunch
                )
            }
        }
    }
}

// 添加膳食视图
struct AddMealView: View {
    @Binding var meal: MealRecord
    var onSave: (MealRecord) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("添加膳食")
                    .font(.headline)
                
                TextField("膳食名称", text: $meal.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("膳食类型", selection: $meal.type) {
                    ForEach(MealRecord.MealType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                // 卡路里
                Stepper(value: $meal.calories, in: 0...2000, step: 50) {
                    HStack {
                        Text("卡路里:")
                        Spacer()
                        Text("\(Int(meal.calories)) 千卡")
                    }
                }
                
                // 蛋白质
                Stepper(value: $meal.protein, in: 0...200, step: 5) {
                    HStack {
                        Text("蛋白质:")
                        Spacer()
                        Text("\(Int(meal.protein)) 克")
                    }
                }
                
                // 碳水
                Stepper(value: $meal.carbs, in: 0...200, step: 5) {
                    HStack {
                        Text("碳水:")
                        Spacer()
                        Text("\(Int(meal.carbs)) 克")
                    }
                }
                
                // 脂肪
                Stepper(value: $meal.fat, in: 0...200, step: 5) {
                    HStack {
                        Text("脂肪:")
                        Spacer()
                        Text("\(Int(meal.fat)) 克")
                    }
                }
                
                // 保存按钮
                Button(action: {
                    meal.timestamp = Date()
                    onSave(meal)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("保存")
                }
                .buttonStyle(BorderedButtonStyle(tint: .blue))
                .disabled(meal.name.isEmpty)
            }
            .padding()
        }
    }
}

// 个人资料视图
struct ProfileView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 用户基本信息
                VStack(spacing: 5) {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                    
                    Text("\(userProfileManager.gender.rawValue) · \(userProfileManager.age) 岁")
                        .font(.subheadline)
                }
                .padding(.bottom, 10)
                
                // 身体数据
                GroupBox(label: Text("身体数据")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("身高")
                            Spacer()
                            Text("\(Int(userProfileManager.height)) cm")
                        }
                        
                        HStack {
                            Text("体重")
                            Spacer()
                            Text("\(String(format: "%.1f", userProfileManager.weight)) kg")
                        }
                        
                        HStack {
                            Text("BMI")
                            Spacer()
                            let bmi = userProfileManager.weight / pow(userProfileManager.height / 100, 2)
                            Text("\(String(format: "%.1f", bmi))")
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                // 目标设置
                GroupBox(label: Text("目标设置")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("健身目标")
                            Spacer()
                            Text(userProfileManager.fitnessGoal.rawValue)
                        }
                        
                        HStack {
                            Text("活动水平")
                            Spacer()
                            Text(userProfileManager.activityLevel.rawValue)
                        }
                        
                        HStack {
                            Text("饮食偏好")
                            Spacer()
                            Text(userProfileManager.dietaryPreference.rawValue)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                // 数据计算
                GroupBox(label: Text("每日能量")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("基础代谢率")
                            Spacer()
                            Text("\(Int(userProfileManager.calculateBMR())) 千卡")
                        }
                        
                        HStack {
                            Text("总能量消耗")
                            Spacer()
                            Text("\(Int(userProfileManager.calculateTDEE())) 千卡")
                        }
                        
                        HStack {
                            Text("目标卡路里")
                            Spacer()
                            Text("\(Int(userProfileManager.calculateCalorieTarget())) 千卡")
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                // 刷新健康数据按钮
                Button(action: {
                    healthKitManager.fetchHealthData()
                    // 如果 HealthKit 有更新的体重数据，更新用户资料
                    if healthKitManager.weight > 0 {
                        userProfileManager.weight = healthKitManager.weight
                    }
                }) {
                    Label("刷新健康数据", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(BorderedButtonStyle(tint: .blue))
                .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HealthKitManager())
            .environmentObject(UserProfileManager())
            .environmentObject(NutritionAIService())
    }
}
