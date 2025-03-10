import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // 发布属性，当这些属性改变时会通知观察者
    @Published var restingCalories: Double = 0
    @Published var activeCalories: Double = 0
    @Published var steps: Int = 0
    @Published var weight: Double = 0
    @Published var height: Double = 0
    @Published var isAuthorized: Bool = false
    @Published var recentWorkouts: [HKWorkout] = []
    
    init() {
        // 初始化时检查健康数据访问权限
        checkHealthKitAuthorization()
    }
    
    // 检查 HealthKit 授权状态
    func checkHealthKitAuthorization() {
        // 首先确认设备支持 HealthKit
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 在此设备上不可用")
            return
        }
        
        // 准备我们需要请求的健康数据类型
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.workoutType()
        ]
        
        // 请求授权
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.isAuthorized = true
                    self.fetchHealthData()
                    print("HealthKit 授权成功")
                } else {
                    self.isAuthorized = false
                    if let error = error {
                        print("HealthKit 授权失败: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // 获取健康数据
    func fetchHealthData() {
        if isAuthorized {
            fetchRestingCalories()
            fetchActiveCalories()
            fetchSteps()
            fetchWeight()
            fetchHeight()
            fetchRecentWorkouts()
        }
    }
    
    // 获取静息卡路里
    func fetchRestingCalories() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("获取静息卡路里失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                self.restingCalories = calories
                print("静息卡路里: \(calories) kcal")
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取活动卡路里
    func fetchActiveCalories() {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("获取活动卡路里失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                self.activeCalories = calories
                print("活动卡路里: \(calories) kcal")
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取步数
    func fetchSteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("获取步数失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            DispatchQueue.main.async {
                self.steps = steps
                print("步数: \(steps)")
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取体重
    func fetchWeight() {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { (_, samples, error) in
            guard let samples = samples, let weightSample = samples.first as? HKQuantitySample else {
                print("获取体重失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            let weight = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            DispatchQueue.main.async {
                self.weight = weight
                print("体重: \(weight) kg")
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取身高
    func fetchHeight() {
        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height) else { return }
        
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { (_, samples, error) in
            guard let samples = samples, let heightSample = samples.first as? HKQuantitySample else {
                print("获取身高失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            let height = heightSample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
            DispatchQueue.main.async {
                self.height = height
                print("身高: \(height) cm")
            }
        }
        
        healthStore.execute(query)
    }
    
    // 获取最近的锻炼记录
    func fetchRecentWorkouts() {
        let workoutType = HKObjectType.workoutType()
        
        // 查询最近7天的锻炼
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 10, sortDescriptors: [sortDescriptor]) { (_, samples, error) in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("获取锻炼记录失败: \(error?.localizedDescription ?? "未知错误")")
                return
            }
            
            DispatchQueue.main.async {
                self.recentWorkouts = workouts
                print("获取到 \(workouts.count) 条最近锻炼记录")
            }
        }
        
        healthStore.execute(query)
    }
    
    // 根据HealthKit的锻炼类型转换为应用内的WorkoutType
    func mapHKWorkoutToAppWorkoutType(_ hkWorkout: HKWorkout) -> WorkoutType {
        switch hkWorkout.workoutActivityType {
        case .traditionalStrengthTraining, .functionalStrengthTraining, .crossTraining:
            return .strength
        case .running, .cycling, .swimming, .walking, .hiking:
            return .cardio
        case .highIntensityIntervalTraining:
            return .hiit
        case .yoga, .mindAndBody:
            return .yoga
        case .flexibility:
            return .flexibility
        default:
            return .none
        }
    }
}