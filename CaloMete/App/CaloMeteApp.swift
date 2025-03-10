import SwiftUI
import HealthKit

// 主应用入口
@main
struct CaloMeteApp: App {
    // 创建 HealthKitManager 和 UserProfileManager 实例
    // 使用 StateObject 确保它们在整个应用生命周期内保持活跃
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var userProfileManager = UserProfileManager()
    
    var body: some Scene {
        WindowGroup {
            // 根据用户是否已设置个人资料决定显示哪个视图
            if userProfileManager.isProfileSetup {
                ContentView()
                    .environmentObject(healthKitManager)
                    .environmentObject(userProfileManager)
            } else {
                OnboardingView()
                    .environmentObject(userProfileManager)
            }
        }
    }
}

// 内容视图 - 应用的主界面
struct ContentView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 主页/仪表盘
            DashboardView()
                .tabItem {
                    Label("主页", systemImage: "house.fill")
                }
                .tag(0)
            
            // 餐食推荐
            MealRecommendationsView()
                .tabItem {
                    Label("餐食", systemImage: "fork.knife")
                }
                .tag(1)
            
            // 用户资料
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(2)
        }
        .onAppear {
            // 应用出现时刷新健康数据
            healthKitManager.fetchHealthData()
        }
    }
}

// 初始设置视图
struct OnboardingView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var currentStep = 1
    
    var body: some View {
        VStack {
            Text("设置您的个人资料")
                .font(.largeTitle)
                .bold()
                .padding()
            
            TabView(selection: $currentStep) {
                // 第一步：基本信息
                VStack(spacing: 20) {
                    Text("基本信息")
                        .font(.title)
                        .padding()
                    
                    // 身高输入
                    HStack {
                        Text("身高:")
                        Slider(value: $userProfileManager.height, in: 100...220, step: 1)
                        Text("\(Int(userProfileManager.height)) cm")
                    }
                    .padding()
                    
                    // 体重输入
                    HStack {
                        Text("体重:")
                        Slider(value: $userProfileManager.weight, in: 30...150, step: 0.5)
                        Text("\(String(format: "%.1f", userProfileManager.weight)) kg")
                    }
                    .padding()
                    
                    // 年龄输入
                    HStack {
                        Text("年龄:")
                        Slider(value: Binding(
                            get: { Double(userProfileManager.age) },
                            set: { userProfileManager.age = Int($0) }
                        ), in: 18...100, step: 1)
                        Text("\(userProfileManager.age) 岁")
                    }
                    .padding()
                    
                    // 性别选择
                    Picker("性别", selection: $userProfileManager.gender) {
                        ForEach(Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Button("下一步") {
                        withAnimation {
                            currentStep = 2
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .tag(1)
                
                // 第二步：健身目标
                VStack(spacing: 20) {
                    Text("健身目标")
                        .font(.title)
                        .padding()
                    
                    // 健身目标选择
                    VStack(alignment: .leading, spacing: 15) {
                        Text("您的主要目标是什么?")
                            .font(.headline)
                        
                        ForEach(FitnessGoal.allCases) { goal in
                            Button(action: {
                                userProfileManager.fitnessGoal = goal
                            }) {
                                HStack {
                                    Text(goal.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if userProfileManager.fitnessGoal == goal {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    // 活动水平选择
                    VStack(alignment: .leading, spacing: 15) {
                        Text("您的日常活动水平是?")
                            .font(.headline)
                        
                        ForEach(ActivityLevel.allCases) { level in
                            Button(action: {
                                userProfileManager.activityLevel = level
                            }) {
                                HStack {
                                    Text(level.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if userProfileManager.activityLevel == level {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    HStack {
                        Button("上一步") {
                            withAnimation {
                                currentStep = 1
                            }
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        Button("下一步") {
                            withAnimation {
                                currentStep = 3
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .tag(2)
                
                // 第三步：饮食偏好
                VStack(spacing: 20) {
                    Text("饮食偏好")
                        .font(.title)
                        .padding()
                    
                    // 饮食偏好选择
                    VStack(alignment: .leading, spacing: 15) {
                        Text("您有特殊的饮食偏好吗?")
                            .font(.headline)
                        
                        ForEach(DietaryPreference.allCases) { preference in
                            Button(action: {
                                userProfileManager.dietaryPreference = preference
                            }) {
                                HStack {
                                    Text(preference.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if userProfileManager.dietaryPreference == preference {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    HStack {
                        Button("上一步") {
                            withAnimation {
                                currentStep = 2
                            }
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        Button("完成设置") {
                            // 标记个人资料设置已完成
                            userProfileManager.isProfileSetup = true
                            userProfileManager.saveProfile()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

// 预览
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HealthKitManager())
            .environmentObject(UserProfileManager())
    }
}
