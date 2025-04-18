//
//  SampleData.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import HealthKit
import SwiftUI
import SwiftData

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let schema = Schema([
            OMeditate.self,
            O478Breath.self,
            OBoxBreath.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        let meditate = OMeditate(date: .now, duration: 300)
        let four78 = O478Breath(date: .now.addingTimeInterval(-7200), duration: 200, rounds: 8)
        let box = OBoxBreath(date: .now.addingTimeInterval(-10800), duration: 600, rounds: 40)
        container.mainContext.insert(meditate)
        container.mainContext.insert(four78)
        container.mainContext.insert(box)
        
        let meditateOld = OMeditate(date: .now.addingTimeInterval(-86400), duration: 300)
        let four78Old = O478Breath(date: .now.addingTimeInterval(-93600), duration: 200, rounds: 8)
        let boxOld = OBoxBreath(date: .now.addingTimeInterval(-172800), duration: 600, rounds: 40)
        container.mainContext.insert(meditateOld)
        container.mainContext.insert(four78Old)
        container.mainContext.insert(boxOld)
        
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}

class MockWorkout {
    func createMockWorkout() -> HKWorkout {
        // Set workout parameters
        let workoutType = HKWorkoutActivityType.hiking
        
        // Create start and end dates
        let now = Date()
        let startDate = now.addingTimeInterval(-3600) // 1 hour ago
        let endDate = now
        
        // Energy burned in calories
        let energyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 325.0)
        
        // Distance in meters
        let distance = HKQuantity(unit: HKUnit.meter(), doubleValue: 5000.0)
        
        // Create the workout
        let workout = HKWorkout(
            activityType: workoutType,
            start: startDate,
            end: endDate,
            duration: 3600, // 1 hour in seconds
            totalEnergyBurned: energyBurned,
            totalDistance: distance,
            metadata: [
                "source": "Mock Data",
                "location": "Outdoor",
                "weather": "Sunny"
            ]
        )
        
        return workout
    }

    func createMockWorkoutEvents(workout: HKWorkout) {
        // Create some workout events
        let _ = [
            HKWorkoutEvent(
                type: .pause,
                dateInterval: DateInterval(
                    start: workout.startDate.addingTimeInterval(1200), // 20 minutes in
                    duration: 180 // 3 minute pause
                ),
                metadata: nil
            ),
            HKWorkoutEvent(
                type: .lap,
                dateInterval: DateInterval(
                    start: workout.startDate.addingTimeInterval(1800), // 30 minutes in
                    duration: 0
                ),
                metadata: nil
            ),
            HKWorkoutEvent(
                type: .motionPaused,
                dateInterval: DateInterval(
                    start: workout.startDate.addingTimeInterval(2700), // 45 minutes in
                    duration: 120 // 2 minute pause
                ),
                metadata: nil
            )
        ]
    }

    // Optionally, you could add heart rate or other samples to the workout
    func createWorkoutSamples(workout: HKWorkout) {
        // Create a heart rate sample
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        
        // Mock a heart rate of 140 bpm at 30 minutes into the workout
        let heartRateQuantity = HKQuantity(unit: heartRateUnit, doubleValue: 140.0)
        let _ = HKQuantitySample(
            type: heartRateType,
            quantity: heartRateQuantity,
            start: workout.startDate.addingTimeInterval(1800), // 30 minutes in
            end: workout.startDate.addingTimeInterval(1800)
        )
    }
}
