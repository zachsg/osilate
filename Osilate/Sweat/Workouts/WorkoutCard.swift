//
//  WorkoutCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/16/25.
//

import HealthKit
import SwiftUI

struct WorkoutCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(HealthController.self) private var healthController
    
    let workout: HKWorkout
    
    @State private var showingMap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: activityTypeIcon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: -1) {
                    Text(activityTypeString)
                        .font(.headline)
                    
                    Text(formattedDate)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formattedDuration)
                    .font(.headline)
                    .padding(6)
                    .background(.accent.opacity(0.2))
                    .cornerRadius(6)
            }
            .padding(.horizontal)
            
            // Stats section
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
                
                if isOutdoors {
                    Spacer()
                    Button {
                        withAnimation {
                            showingMap.toggle()
                        }
                    } label: {
                        Image(systemName: "map")
                    }
                }
            }
            .padding(.horizontal)
            
//            if isOutdoors {
//                if showingMap {
//                    WorkoutMap(workout: workout)
//                        .padding(.horizontal)
//                }
//            }
        }
        .padding(.vertical, 12)
        .background {
            if colorScheme == .dark {
                Rectangle().fill(Material.regularMaterial)
            } else {
                Rectangle().fill(Color.white) // Assuming BackgroundStyle.background is a Color
            }
        }
        .cornerRadius(12)
        .padding(.vertical, 4)
        .sheet(isPresented: $showingMap) {
            WorkoutMap(workout: workout, sheetIsShowing: $showingMap)
        }

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
        .environment(HealthController())
}
