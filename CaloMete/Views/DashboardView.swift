import SwiftUI
import HealthKit

struct DashboardView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 今日概览卡片
                VStack(alignment: .leading, spacing: 10) {
                    Text("今日概览")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        // 静息卡路里卡片
                        MetricCard(
                            title: "静息卡路里",
                            value: String(format: "%.0f", healthKitManager.restingCalories),
                            unit: "kcal",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        // 活动卡路里卡片
                        MetricCard(
                            title: "活动卡路里",
                            value: String(format: "%.0f", healthKitManager.activeCalories),
                            unit: "kcal",
                            icon: "bolt.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        // 步数卡片
                        MetricCard(
                            title: "步数",
                            value: "\(healthKitManager.steps)",
                            unit: "步",
                            icon: "figure.walk",
                            color: .blue
                        )
                        
                        // 目标进度卡片
                        let totalCalories = healthKitManager.restingCalories + healthKitManager.activeCalories
                        let targetCalories = userProfileManager.calculateCalorieTarget()
                        let progress = min(totalCalories / targetCalories, 1.0)
                        
                        MetricCard(
                            title: "能量消耗进度",
                            value: String(format: "%.0f%%", progress * 100),
                            unit: "",
                            icon: "chart.bar.fill",
                            color: .purple,
                            showProgressBar: true,
                            progress: progress
                        )
                    }
                    .padding(.horizontal)
                }
                
                // 营养和能量摄入推荐
                VStack(alignment: .leading, spacing: 10) {
                    Text("今日推荐摄入")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    let targetCalories = userProfileManager.calculateCalorieTarget()
                    let recommendation = userProfileManager.generateNutritionRecommendation()
                    
                    HStack(spacing: 12) {
                        // 推荐卡路里
                        MetricCard(
                            title: "总卡路里",
                            value: String(format: "%.0f", targetCalories),
                            unit: "kcal",
                            icon: "flame.fill",
                            color: .red
                        )
                        
                        // 推荐蛋白质
                        MetricCard(
                            title: "蛋白质",
                            value: String(format: "%.0f", recommendation.proteinGrams),
                            unit: "g",
                            icon: "circle.grid.3x3.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        // 推荐碳水
                        MetricCard(
                            title: "碳水化合物",
                            value: String(format: "%.0f", recommendation.carbsGrams),
                            unit: "g",
                            icon: "circle.grid.2x2.fill",
                            color: .orange
                        )
                        
                        // 推荐脂肪
                        MetricCard(
                            title: "脂肪",
                            value: String(format: "%.0f", recommendation.fatGrams),
                            unit: "g",
                            icon: "drop.fill",
                            color: .yellow
                        )
                    }
                    .padding(.horizontal)
                    
                    if !recommendation.specialNote.isEmpty {
                        Text(recommendation.specialNote)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 5)
                    }
                }
                
                // 最近运动记录
                VStack(alignment: .leading, spacing: 10) {
                    Text("最近运动")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if healthKitManager.recentWorkouts.isEmpty {
                        Text("暂无最近的运动记录")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(healthKitManager.recentWorkouts.prefix(5), id: \.startDate) { workout in
                                    WorkoutCard(workout: workout)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // 刷新按钮
                Button(action: {
                    healthKitManager.fetchHealthData()
                }) {
                    Label("刷新数据", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

// 指标卡片
struct MetricCard: View {
    var title: String
    var value: String
    var unit: String
    var icon: String
    var color: Color
    var showProgressBar: Bool = false
    var progress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.headline)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if showProgressBar {
                ProgressBar(progress: progress, color: color)
                    .frame(height: 5)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}

// 进度条
struct ProgressBar: View {
    var progress: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .opacity(0.2)
                    .foregroundColor(color)
                
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(progress))
                    .foregroundColor(color)
            }
            .cornerRadius(5)
        }
    }
}

// 运动记录卡片
struct WorkoutCard: View {
    var workout: HKWorkout
    
    var workoutTypeIcon: String {
        switch workout.workoutActivityType {
        case .traditionalStrengthTraining, .functionalStrengthTraining, .crossTraining:
            return "dumbbell"
        case .running:
            return "figure.run"
        case .cycling:
            return "bicycle"
        case .swimming:
            return "figure.pool.swim"
        case .walking, .hiking:
            return "figure.walk"
        case .yoga, .mindAndBody:
            return "figure.mind.and.body"
        case .highIntensityIntervalTraining:
            return "bolt.heart"
        default:
            return "figure.mixed.cardio"
        }
    }
    
    var workoutTypeName: String {
        switch workout.workoutActivityType {
        case .traditionalStrengthTraining, .functionalStrengthTraining:
            return "力量训练"
        case .running:
            return "跑步"
        case .cycling:
            return "骑行"
        case .swimming:
            return "游泳"
        case .walking:
            return "步行"
        case .hiking:
            return "徒步"
        case .yoga:
            return "瑜伽"
        case .mindAndBody:
            return "身心"
        case .highIntensityIntervalTraining:
            return "HIIT"
        default:
            return "活动"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: workoutTypeIcon)
                    .foregroundColor(.orange)
                
                Text(workoutTypeName)
                    .font(.caption)
                    .bold()
            }
            
            let duration = Int(workout.duration / 60) // 分钟
            Text("\(duration) 分钟")
                .font(.caption2)
            
            if let caloriesBurned = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
                Text("\(Int(caloriesBurned)) 千卡")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            
            Text(workout.startDate, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .frame(width: 120)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(HealthKitManager())
            .environmentObject(UserProfileManager())
    }
}