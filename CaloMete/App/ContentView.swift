import SwiftUI
import HealthKit

struct MetricCard: View {
    var title: String
    var value: String
    var unit: String
    var icon: String
    var color: Color
    var showProgressBar: Bool = false
    var progress: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if showProgressBar {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}

struct DashboardView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    
    var body: some View {
        NavigationView {
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
                        
                        let calorieTarget = userProfileManager.calculateCalorieTarget()
                        // 假设蛋白质占 30%，碳水占 45%，脂肪占 25%
                        let proteinCalories = calorieTarget * 0.3
                        let carbCalories = calorieTarget * 0.45
                        let fatCalories = calorieTarget * 0.25
                        
                        // 转换为克数 (蛋白质和碳水 4 卡/克，脂肪 9 卡/克)
                        let proteinGrams = proteinCalories / 4
                        let carbGrams = carbCalories / 4
                        let fatGrams = fatCalories / 9
                        
                        VStack(spacing: 15) {
                            HStack {
                                Text("总热量")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(Int(calorieTarget)) 千卡")
                                    .foregroundColor(.orange)
                                    .fontWeight(.bold)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("蛋白质")
                                Spacer()
                                Text("\(Int(proteinGrams)) 克")
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("碳水化合物")
                                Spacer()
                                Text("\(Int(carbGrams)) 克")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("脂肪")
                                Spacer()
                                Text("\(Int(fatGrams)) 克")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // 刷新健康数据按钮
                    Button(action: {
                        healthKitManager.fetchHealthData()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("刷新健康数据")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .padding(.vertical)
            }
            .navigationTitle("主页")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(HealthKitManager())
            .environmentObject(UserProfileManager())
    }
}
