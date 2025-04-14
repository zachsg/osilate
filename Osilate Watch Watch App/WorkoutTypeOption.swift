//
//  WorkoutTypeOption.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/13/25.
//

import HealthKit
import SwiftUI

struct WorkoutTypeOption: View {
    @Bindable var workoutManager: WorkoutManager
    @Binding var shouldNavigate: Bool
    
    var workoutType: HKWorkoutActivityType
    
    @State private var isOutdoors = false {
        didSet {
            if isOutdoors {
                workoutManager.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    var body: some View {
        HStack {
            Button {
                workoutManager.selectedWorkout = workoutType
                shouldNavigate = true
            } label: {
                Label(workoutType.name, systemImage: workoutType.systemName(outdoors: isOutdoors))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if workoutType.canGps {
                VStack {
                    Toggle("Use GPS", isOn: $isOutdoors.animation())
                        .labelsHidden()
                    Text("GPS")
                        .font(.caption2.smallCaps())
                }
            }
        }
        .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        .onChange(of: isOutdoors) { oldValue, newValue in
            workoutManager.isOutdoors = newValue
        }
    }
}

#Preview {
    WorkoutTypeOption(workoutManager: WorkoutManager(), shouldNavigate: .constant(false), workoutType: .walking)
}
