//
//  Workouts.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/16/25.
//

import HealthKit
import SwiftUI

struct Workouts: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    
    @State private var workoutList = [HKWorkout]()
    @State private var loadingWorkouts = true
    @State private var zoneDurations: [OZone: TimeInterval] = [:]
    @State private var loadingZones = true
    
    var body: some View {
        Group {
            ZonesSection(zoneDurations: $zoneDurations, loading: $loadingZones, showToday: $showToday)
            
            WorkoutsSection(workoutList: $workoutList, loading: $loadingWorkouts, showToday: $showToday)
        }
        .onAppear {
            Task {
                await fetchAll()
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await fetchAll()
                }
            }
        }
        .onChange(of: showToday) { oldValue, newValue in
            Task {
                await fetchAll()
            }
        }
    }
    
    private func fetchAll() async {
        await fetchWorkouts()
        await fetchZones()
    }
    
    private func fetchWorkouts() async {
        await MainActor.run {
            loadingWorkouts = true
        }
        
        let workouts = await healthController.fetchWorkouts(todayOnly: showToday ? true: false)
        
        await MainActor.run {
            workoutList = workouts
            loadingWorkouts = false
        }
    }
    
    private func fetchZones() async {
        await MainActor.run {
            loadingZones = true
        }
        
        let zones = await healthController.fetchZones(for: workoutList)
        
        await MainActor.run {
            zoneDurations = zones
            loadingZones = false
        }
    }
}

#Preview {
    Workouts()
        .environment(HealthController())
}
