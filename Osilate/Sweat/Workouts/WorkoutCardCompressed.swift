//
//  WorkoutCardCompressed.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/17/25.
//

import HealthKit
import SwiftUI

struct WorkoutCardCompressed: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(HealthController.self) private var healthController
    
    let workout: HKWorkout
    
    @State private var showingMap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                Text("On")
                Text(formattedDate)
                    .fontWeight(.semibold)
                Text("for")
                Text(formattedDuration)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.top, 8)
            .font(.footnote)
    
            HStack(spacing: 20) {
                if isOutdoors {
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
                }
                
                statView(title: "Calories", value: formattedCalories)
                
                if workout.workoutActivities.count > 0 {
                    Divider().frame(height: 30)
                    statView(title: "Segments", value: "\(workout.workoutActivities.count)")
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(activityTypeString)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Views
    
    private func statView(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Computed Properties
    private var isOutdoors: Bool {
        var isOutdoors = false
        
        switch workout.workoutActivityType {
        case .elliptical, .cooldown, .yoga, .functionalStrengthTraining, .other:
            isOutdoors = false
        case .hiking:
            isOutdoors = true
        case .running, .cycling, .walking:
            if let indoorWorkout = workout.metadata?[HKMetadataKeyIndoorWorkout] as? Bool {
                if indoorWorkout {
                    isOutdoors = false
                } else {
                    isOutdoors = true
                }
            }
        default:
            isOutdoors = false
        }
        
        return isOutdoors
    }
    
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
        case .elliptical:
            return "Elliptical"
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
            return "figure.outdoor.cycle"
        case .walking:
            return "figure.walk"
        case .functionalStrengthTraining:
            return "figure.strengthtraining.functional"
        case .elliptical:
            return "figure.elliptical"
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
    
    var formattedCalories: String {
        var kilocalories = 0.0
        
        let energyBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        if let statistics = workout.statistics(for: energyBurnedType),
           let totalEnergy = statistics.sumQuantity() {
            kilocalories = totalEnergy.doubleValue(for: .kilocalorie())
        }
        
        return String(format: "%.0f", kilocalories)
    }
}

#Preview {
    WorkoutCardCompressed(workout: MockWorkout().createMockWorkout())
        .environment(HealthController())
}
