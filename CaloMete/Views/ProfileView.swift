import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 用户头像和基本信息
                VStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text("\(userProfileManager.gender.rawValue) · \(userProfileManager.age) 岁")
                        .font(.headline)
                    
                    Text("目标: \(userProfileManager.fitnessGoal.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // 身体数据
                GroupBox(label: 
                    HStack {
                        Image(systemName: "figure.stand")
                        Text("身体数据")
                            .font(.headline)
                    }
                ) {
                    VStack(spacing: 15) {
                        DataRow(title: "身高", value: "\(Int(userProfileManager.height)) cm", iconName: "arrow.up.and.down")
                        
                        DataRow(title: "体重", value: "\(String(format: "%.1f", userProfileManager.weight)) kg", iconName: "scalemass", color: .blue)
                        
                        DataRow(title: "BMI", value: {
                            let bmi = userProfileManager.weight / pow(userProfileManager.height / 100, 2)
                            var bmiCategory = ""
                            var color: Color = .primary
                            
                            if bmi < 18.5 {
                                bmiCategory = " (偏瘦)"
                                color = .blue
                            } else if bmi < 24 {
                                bmiCategory = " (正常)"
                                color = .green
                            } else if bmi < 28 {
                                bmiCategory = " (超重)"
                                color = .orange
                            } else {
                                bmiCategory = " (肥胖)"
                                color = .red
                            }
                            
                            return Text("\(String(format: "%.1f", bmi))" + bmiCategory)
                                .foregroundColor(color)
                            
                        }(), iconName: "chart.bar", color: .purple)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // 营养目标
                GroupBox(label: 
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("能量目标")
                            .font(.headline)
                    }
                ) {
                    VStack(spacing: 15) {
                        DataRow(title: "基础代谢", value: "\(Int(userProfileManager.calculateBMR())) 千卡/天", iconName: "bed.double", color: .orange)
                        
                        DataRow(title: "活动水平", value: userProfileManager.activityLevel.rawValue, iconName: "figure.walk")
                        
                        DataRow(title: "每日能量消耗", value: "\(Int(userProfileManager.calculateTDEE())) 千卡", iconName: "bolt.fill", color: .yellow)
                        
                        DataRow(title: "目标摄入", value: "\(Int(userProfileManager.calculateCalorieTarget())) 千卡", iconName: "target", color: .red)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // 饮食偏好
                GroupBox(label: 
                    HStack {
                        Image(systemName: "fork.knife")
                        Text("饮食偏好")
                            .font(.headline)
                    }
                ) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        
                        Text(userProfileManager.dietaryPreference.rawValue)
                        
                        Spacer()
                        
                        Button(action: {
                            // TODO: 添加编辑饮食偏好的功能
                        }) {
                            Text("更改")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                
                // 刷新健康数据
                Button(action: {
                    healthKitManager.fetchHealthData()
                    
                    // 如果 HealthKit 有更新的体重数据，更新用户资料
                    if healthKitManager.weight > 0 {
                        userProfileManager.weight = healthKitManager.weight
                    }
                    if healthKitManager.height > 0 {
                        userProfileManager.height = healthKitManager.height
                    }
                }) {
                    Label("刷新健康数据", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer(minLength: 30)
            }
        }
    }
}

struct DataRow: View {
    var title: String
    var value: String
    var iconName: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// 重载 DataRow 以接受 Text 类型的 value
struct DataRow_Text: View {
    var title: String
    var value: Text
    var iconName: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(color)
                .frame(width: 25)
            
            Text(title)
            
            Spacer()
            
            value
        }
    }
}

extension DataRow {
    init(title: String, value: Text, iconName: String, color: Color = .primary) {
        self.title = title
        self.value = ""
        self.iconName = iconName
        self.color = color
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserProfileManager())
            .environmentObject(HealthKitManager())
    }
}