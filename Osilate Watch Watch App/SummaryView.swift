//
//  SummaryView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/12/25.
//

import HealthKit
import SwiftUI

struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(WorkoutManager.self) private var workoutManager
    
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        if workoutManager.workout == nil {
            ProgressView("Saving Workout")
                .toolbarVisibility(.hidden, for: .navigationBar)
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    SummaryMetricView(
                        title: "Total time",
                        value: durationFormatter.string(
                            from: workoutManager.workout?.duration ?? 0.0
                        ) ?? ""
                    )
                    .tint(.yellow)
                    
                    SummaryMetricView(
                        title: "Total Distance",
                        value: Measurement(
                            value: workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0,
                            unit: UnitLength.meters
                        ).formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .road
                            )
                        )
                    )
                    .tint(.green)
                    
                    SummaryMetricView(
                        title: "Total Energy",
                        value: Measurement(
                            value: workoutManager.activeEnergy,
                            unit: UnitEnergy.kilocalories
                        ).formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .workout,
                                numberFormatStyle: .number.precision(
                                    .fractionLength(0)
                                )
                            )
                        )
                    )
                    .tint(.pink)
                    
                    SummaryMetricView(
                        title: "Avg. Heart Rate",
                        value: workoutManager.averageHeartRate
                            .formatted(
                                .number.precision(.fractionLength(0))
                            )
                        + " bpm"
                    )
                    .tint(.red)
                    
                    Text("Activity Rings")
                    ActivityRingsView(
                        healthStore: workoutManager.healthStore
                    )
                    .frame(width: 50, height: 50)
                    
                    Button("Done") {
                        workoutManager.showingSummaryView = false
                        dismiss()
                    }
                }
                .scenePadding()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SummaryView()
        .environment(WorkoutManager())
}

struct SummaryMetricView: View {
    var title: String
    var value: String
    
    var body: some View {
        Text(title)
        
        Text(value)
            .font(.title2.lowercaseSmallCaps())
            .foregroundStyle(.tint)
        
        Divider()
    }
}
