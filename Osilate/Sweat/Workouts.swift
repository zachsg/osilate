//
//  Workouts.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/16/25.
//

import HealthKit
import SwiftUI

struct Workouts: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    
    @State private var workoutList = [HKWorkout]()
    @State private var loading = true
    
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
        .onAppear {
            Task {
                await fetchWorkouts()
            }
        }
        .onChange(of: showToday) { oldValue, newValue in
            Task {
                await fetchWorkouts()
            }
        }
    }
    
    private func fetchWorkouts() async {
        loading = true
        workoutList = await healthController.fetchTodaysWorkouts(todayOnly: showToday ? true: false)
        loading = false
    }
}

#Preview {
    Workouts()
        .environment(HealthController())
}
