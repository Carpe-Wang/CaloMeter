import SwiftUI

struct MealRecommendationsView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var nutritionAIService = NutritionAIService()
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("今日膳食推荐")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                if nutritionAIService.isLoading {
                    ProgressView()
                        .padding()
                    Text("生成建议中...")
                        .font(.subheadline)
                } else if let recommendation = nutritionAIService.currentRecommendation {
                    // 显示今日推荐
                    VStack(alignment: .leading, spacing: 10) {
                        Text(recommendation.title)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if !recommendation.specialNote.isEmpty {
                            Text(recommendation.specialNote)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        
                        // 宏量素柱状图
                        HStack(spacing: 20) {
                            MacronutrientCard(
                                name: "蛋白质",
                                value: Int(recommendation.proteinGrams),
                                percentage: recommendation.proteinPercentage,
                                color: .red
                            )
                            
                            MacronutrientCard(
                                name: "碳水",
                                value: Int(recommendation.carbsGrams),
                                percentage: recommendation.carbsPercentage,
                                color: .blue
                            )
                            
                            MacronutrientCard(
                                name: "脂肪",
                                value: Int(recommendation.fatGrams),
                                percentage: recommendation.fatPercentage,
                                color: .yellow
                            )
                        }
                        .padding()
                        
                        Divider()
                        
                        // 各餐建议
                        Text("膳食计划")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(nutritionAIService.mealSuggestions, id: \.description) { meal in
                            MealSuggestionCard(mealSuggestion: meal)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                        }
                    }
                } else {
                    VStack {
                        Text("未能生成推荐")
                            .font(.headline)
                            .padding()
                        
                        Button(action: {
                            nutritionAIService.generateRecommendations(
                                userProfile: userProfileManager,
                                healthData: healthKitManager
                            )
                        }) {
                            Text("重新生成")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                // 刷新按钮
                Button(action: {
                    nutritionAIService.generateRecommendations(
                        userProfile: userProfileManager,
                        healthData: healthKitManager
                    )
                }) {
                    Label("刷新推荐", systemImage: "arrow.clockwise")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            nutritionAIService.generateRecommendations(
                userProfile: userProfileManager,
                healthData: healthKitManager
            )
        }
    }
}

// 宏量素卡片
struct MacronutrientCard: View {
    var name: String
    var value: Int
    var percentage: Double
    var color: Color
    
    var body: some View {
        VStack {
            Text(name)
                .font(.subheadline)
                .bold()
            
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 40, height: 100)
                    .opacity(0.2)
                    .foregroundColor(color)
                
                Rectangle()
                    .frame(width: 40, height: CGFloat(percentage * 100))
                    .foregroundColor(color)
            }
            .cornerRadius(5)
            
            Text("\(value)g")
                .font(.caption)
            Text("\(Int(percentage * 100))%")
                .font(.caption)
                .foregroundColor(color)
        }
    }
}

// 膳食建议卡片
struct MealSuggestionCard: View {
    var mealSuggestion: MealSuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(mealSuggestion.type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(mealSuggestion.calories)) 千卡")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            ForEach(mealSuggestion.foodItems, id: \.self) { item in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.gray)
                    
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct MealRecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        MealRecommendationsView()
            .environmentObject(UserProfileManager())
            .environmentObject(HealthKitManager())
    }
}