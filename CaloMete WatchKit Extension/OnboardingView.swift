import SwiftUI
import HealthKit

struct OnboardingView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var currentStep = 1
    @State private var showHealthKitPermission = false
    
    var body: some View {
        TabView(selection: $currentStep) {
            // 欢迎页面
            VStack(spacing: 8) {
                Text("CaloMeter")
                    .font(.headline)
                
                Text("个性化营养建议")
                    .font(.subheadline)
                
                Spacer()
                
                Button(action: {
                    showHealthKitPermission = true
                }) {
                    Text("开始设置")
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderedButtonStyle(tint: .blue))
                .padding(.bottom, 10)
            }
            .tag(1)
            .sheet(isPresented: $showHealthKitPermission) {
                HealthKitPermissionView {
                    withAnimation {
                        currentStep = 2
                    }
                }
            }
            
            // 基本信息
            VStack(spacing: 8) {
                Text("基本信息")
                    .font(.headline)
                
                Picker("性别", selection: $userProfileManager.gender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                
                HStack {
                    Text("年龄:")
                    Spacer()
                    Text("\(userProfileManager.age)")
                }
                
                Slider(value: Binding(
                    get: { Double(userProfileManager.age) },
                    set: { userProfileManager.age = Int($0) }
                ), in: 18...100, step: 1)
                
                Button(action: {
                    withAnimation {
                        currentStep = 3
                    }
                }) {
                    Text("下一步")
                }
                .buttonStyle(BorderedButtonStyle(tint: .blue))
            }
            .padding(.horizontal, 5)
            .tag(2)
            
            // 健身目标
            VStack(spacing: 8) {
                Text("健身目标")
                    .font(.headline)
                
                List {
                    ForEach(FitnessGoal.allCases) { goal in
                        Button(action: {
                            userProfileManager.fitnessGoal = goal
                        }) {
                            HStack {
                                Text(goal.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if userProfileManager.fitnessGoal == goal {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    withAnimation {
                        currentStep = 4
                    }
                }) {
                    Text("下一步")
                }
                .buttonStyle(BorderedButtonStyle(tint: .blue))
            }
            .tag(3)
            
            // 饮食偏好
            VStack(spacing: 8) {
                Text("饮食偏好")
                    .font(.headline)
                
                List {
                    ForEach(DietaryPreference.allCases) { preference in
                        Button(action: {
                            userProfileManager.dietaryPreference = preference
                        }) {
                            HStack {
                                Text(preference.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if userProfileManager.dietaryPreference == preference {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    // 完成设置
                    userProfileManager.isProfileSetup = true
                    userProfileManager.saveProfile()
                }) {
                    Text("完成")
                }
                .buttonStyle(BorderedButtonStyle(tint: .green))
            }
            .tag(4)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            // 尝试从 HealthKit 加载用户数据
            if healthKitManager.isAuthorized {
                if healthKitManager.weight > 0 {
                    userProfileManager.weight = healthKitManager.weight
                }
                if healthKitManager.height > 0 {
                    userProfileManager.height = healthKitManager.height
                }
            }
        }
    }
}

// HealthKit 权限请求视图
struct HealthKitPermissionView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @Environment(\.presentationMode) var presentationMode
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text("健康数据访问")
                .font(.headline)
            
            Text("此应用需要访问您的健康数据以提供个性化建议")
                .font(.caption)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                healthKitManager.checkHealthKitAuthorization()
                presentationMode.wrappedValue.dismiss()
                onComplete()
            }) {
                Text("允许访问")
            }
            .buttonStyle(BorderedButtonStyle(tint: .blue))
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                onComplete()
            }) {
                Text("稍后设置")
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(UserProfileManager())
            .environmentObject(HealthKitManager())
    }
}