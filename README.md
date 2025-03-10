# CaloMeter - AI-Powered Nutrition Advisor for Apple Watch

CaloMeter is an Apple Watch app that leverages your resting calorie expenditure data from Apple Watch, combined with AI-powered recommendations, to provide personalized meal and workout suggestions.

## Features

- **Personalized Nutrition Recommendations**: Based on your activity level, workout history, and fitness goals
- **Real-time Calorie Tracking**: Monitors resting and active calories burned
- **Smart Meal Logging**: Log your meals to receive better recommendations over time
- **Adaptive Suggestions**: Recommendations adapt based on your workout types (strength training, cardio, etc.)
- **HealthKit Integration**: Seamlessly works with Apple Health data (weight, height, workout history)

## How It Works

1. **Initial Setup**: Enter your height, weight, fitness goals, and dietary preferences
2. **Data Collection**: The app automatically collects your resting calorie expenditure data from Apple Watch
3. **AI Analysis**: Based on your profile, health data, and workout history, the AI generates meal recommendations
4. **Adaptive Learning**: As you log meals and complete workouts, recommendations become more personalized

## Requirements

- Apple Watch Series 4 or later
- watchOS 7.0 or later
- iPhone with iOS 14.0 or later
- Xcode 13.0 or later (for development)

## Installation

1. Clone this repository
2. Open the project in Xcode
3. Configure your development team in the project settings
4. Build and run the app on your Apple Watch

## Usage

1. Launch the app on your Apple Watch
2. Complete the initial profile setup (if first time)
3. View your calorie expenditure on the main screen
4. Check the "Recommendations" tab for personalized meal suggestions
5. Log your meals in the "Meal Log" tab
6. Update your workout type after completing exercises to receive better recommendations

## Development

The app is built using SwiftUI and leverages HealthKit for health data access. The recommendation engine uses a rule-based system to provide personalized nutrition advice based on user metrics and activity.

### Project Structure

- **HealthKitManager.swift**: Manages access to health data (calories, steps, weight, height)
- **UserProfileManager.swift**: Handles user profile data and nutrition calculations
- **NutritionAIService.swift**: Provides meal suggestions based on user data
- **ContentView.swift**: Main UI for the Watch app
- **OnboardingView.swift**: User profile setup flow

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Developed by CarpeWang
