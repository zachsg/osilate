//
//  WorkoutCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/16/25.
//

import HealthKit
import SwiftUI

struct WorkoutCard: View {
    let workout: HKWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: activityTypeIcon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading) {
                    Text(activityTypeString)
                        .font(.headline)
                    
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formattedDuration)
                    .font(.headline)
                    .padding(6)
                    .background(.regularMaterial)
                    .cornerRadius(4)
            }
            .padding(.horizontal)
            
            // Stats section
            HStack(spacing: 20) {
                statView(
                    title: "Distance",
                    value: Measurement(
                        value: workout.totalDistance?.doubleValue(for: .meter()) ?? 0,
                        unit: UnitLength.meters
                    )
                    .formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road,
                        )
                    )
                )
                
                Divider().frame(height: 30)
                
                statView(title: "Calories", value: formattedCalories)
                
                if workout.workoutActivities.count > 0 {
                    Divider().frame(height: 30)
                    statView(title: "Segments", value: "\(workout.workoutActivities.count)")
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
    
    // MARK: - Helper Views
    
    private func statView(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Computed Properties
    
    private var activityTypeString: String {
        switch workout.workoutActivityType {
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .walking:
            return "Walking"
        case .functionalStrengthTraining:
            return "Strength Training"
        case .hiking:
            return "Hiking"
        case .cooldown:
            return "Cooldown"
        case .other:
            return "Other"
        case .yoga:
            return "Yoga"
        default:
            return "Workout"
        }
    }
    
    private var activityTypeIcon: String {
        switch workout.workoutActivityType {
        case .running:
            return "figure.run"
        case .cycling:
            return "figure.cycling"
        case .walking:
            return "figure.walk"
        case .functionalStrengthTraining:
            return "figure.strengthtraining.functional"
        case .hiking:
            return "figure.hiking"
        case .cooldown:
            return "figure.cooldown"
        case .other:
            return "figure"
        case .yoga:
            return "figure.mind.and.body"
        default:
            return "figure.mixed.cardio"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, MMM dd"
        return formatter.string(from: workout.startDate)
    }
    
    private var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: workout.duration) ?? "N/A"
    }
    
    private var formattedDistance: String {
        guard let distance = workout.totalDistance else {
            return "N/A"
        }
        
        let distanceInMeters = distance.doubleValue(for: .meter())
        
        if distanceInMeters >= 1000 {
            let distanceInKm = distanceInMeters / 1000
            return String(format: "%.2f km", distanceInKm)
        } else {
            return String(format: "%.0f m", distanceInMeters)
        }
    }
    
    private var formattedCalories: String {
        guard let calories = workout.totalEnergyBurned else {
            return "N/A"
        }
        
        let caloriesValue = calories.doubleValue(for: .kilocalorie())
        return String(format: "%.0f kcal", caloriesValue)
    }
}


#Preview {
    WorkoutCard(workout: MockWorkout().createMockWorkout())
}
