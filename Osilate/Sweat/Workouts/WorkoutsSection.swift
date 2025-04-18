//
//  WorkoutsSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/18/25.
//

import HealthKit
import SwiftUI

struct WorkoutsSection: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var workoutList: [HKWorkout]
    @Binding var loading: Bool
    @Binding var showToday: Bool
    
    var body: some View {
        Section {
            if loading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if workoutList.isEmpty {
                Text("No workouts so far.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(workoutList, id: \.uuid) { workout in
                    WorkoutCard(workout: workout)
                }
            }
        } header: {
            HeaderLabel(title: "Workouts \(showToday ? "Today" : "Past Week")", systemImage: "sun.max", color: .accent)
        }
    }
}

#Preview {
    let workouts = [MockWorkout().createMockWorkout()]
    
    WorkoutsSection(workoutList: .constant(workouts), loading: .constant(false), showToday: .constant(false))
        .environment(HealthController())
}
