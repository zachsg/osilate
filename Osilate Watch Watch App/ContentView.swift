//
//  ContentView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/11/25.
//

import HealthKit
import SwiftUI

struct ContentView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    @AppStorage(maxHrKey) var maxHr = maxHrDefault
    
    var workoutTypes: [HKWorkoutActivityType] = [.walking, .hiking, .running, .cycling, .elliptical, .functionalStrengthTraining, .yoga, .cooldown, .other]
    
    @State private var shouldNavigate = false
    @State private var showingSummarySheet = false
    
    var body: some View {
        NavigationStack {
            List(workoutTypes) { workoutType in
                WorkoutTypeOption(workoutManager: workoutManager, shouldNavigate: $shouldNavigate, workoutType: workoutType)
            }
            .listStyle(.carousel)
            .navigationBarTitle("Workouts")
            .navigationDestination(isPresented: $shouldNavigate) {
                SessionPagingView()
            }
        }
        .onAppear {
            AppStorageSyncManager.shared.activateSession()
            workoutManager.requestAuthorization()
        }
        .onChange(of: workoutManager.showingSummaryView) { oldValue, newValue in
            showingSummarySheet = newValue
            shouldNavigate = false
        }
        .sheet(isPresented: $showingSummarySheet) {
            SummaryView()
        }
    }
}

#Preview {
    ContentView()
        .environment(WorkoutManager())
}

extension HKWorkoutActivityType: @retroactive Identifiable {
    public var id: UInt {
        rawValue
    }
    
    var name: String {
        switch self {
        case .walking:
            return "Walk"
        case .hiking:
            return "Hike"
        case .running:
            return "Run"
        case .cycling:
            return "Bike"
        case .elliptical:
            return "Elliptical"
        case .functionalStrengthTraining:
            return "Strength Training"
        case .yoga:
            return "Yoga"
        case .cooldown:
            return "Cooldown"
        case .other:
            return "Other"
        default:
            return "Unknown"
        }
    }
    
    func systemName(outdoors: Bool = false) -> String {
        switch self {
        case .walking:
            return outdoors ? "figure.walk" : "figure.walk.treadmill"
        case .hiking:
            return "figure.hiking"
        case .running:
            return outdoors ? "figure.run" : "figure.run.treadmill"
        case .cycling:
            return outdoors ? "figure.outdoor.cycle" : "figure.indoor.cycle"
        case .elliptical:
            return "figure.elliptical"
        case .functionalStrengthTraining:
            return "figure.strengthtraining.functional"
        case .yoga:
            return "figure.yoga"
        case .cooldown:
            return "figure.cooldown"
        case .other:
            return "figure.stand"
        default:
            return "Unknown"
        }
    }
    
    var canGps: Bool {
        switch self {
        case .walking, .hiking, .running, .cycling:
            return true
        default:
            return false
        }
    }
}
