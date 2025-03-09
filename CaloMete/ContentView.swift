import SwiftUI
import HealthKit

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
                            .
