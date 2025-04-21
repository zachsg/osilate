//
//  ElevationView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/14/25.
//

import SwiftUI

struct ElevationView: View {
    @Environment(\.locale) private var locale
    @Environment(WorkoutManager.self) private var workoutManager
    
    var elevation: Double {
        workoutManager.elevationStart + (workoutManager.elevationGain - workoutManager.elevationLost)
    }
    
    var body: some View {
        ZStack {
            workoutManager.heartRate.zoneColor().opacity(0.2)
            
            VStack(alignment: .leading) {
                Label {
                    if workoutManager.elevationStart < 0 {
                        Text("Calibrating...")
                    } else {
                        Text(formattedElevation(elevation))
                    }
                } icon: {
                    Text("   Elev.   ")
                        .font(.caption2)
                }
                
                Label {
                    Text(formattedElevation(workoutManager.elevationGain))
                } icon: {
                    Text("   Gain   ")
                        .font(.caption2)
                }
                
                Label {
                    Text(formattedElevation(-workoutManager.elevationLost))
                } icon: {
                    Text("   Loss   ")
                        .font(.caption2)
                }
                
                Label {
                    Text(formattedElevation(workoutManager.elevationGain - workoutManager.elevationLost))
                } icon: {
                    Text("Change")
                        .font(.caption2)
                }
            }
            .font(.title2.monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .scenePadding()
            .padding(.top, 20)
        }
        .ignoresSafeArea()
    }
    
    private func formattedElevation(_ value: Double) -> String {
        // Store the initial measurement in meters
        let measurement = Measurement(value: value, unit: UnitLength.meters)
        
        // Create a formatter that will respect the locale
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit // Use the unit we provide
        formatter.numberFormatter.maximumFractionDigits = 0
        
        // Choose the appropriate unit based on locale (metric vs imperial)
        let useMetric = Locale.current.measurementSystem == .metric
        let unit: UnitLength = useMetric ? .meters : .feet
        
        // Convert to the appropriate unit and format
        return formatter.string(from: measurement.converted(to: unit))
    }
}

#Preview {
    ElevationView()
        .environment(WorkoutManager())
}
