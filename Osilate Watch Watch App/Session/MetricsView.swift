//
//  MetricsView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/12/25.
//

import SwiftUI

struct MetricsView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    var body: some View {
        TimelineView(
            MetricsTimelineSchedule(
                from: workoutManager.builder?.startDate ?? Date()
            )
        ) { context in
            ZStack {
                workoutManager.heartRate.zoneColor().opacity(0.2)
                
                VStack(alignment: .leading) {
                    ElapsedTimeView(
                        elapsedTime: workoutManager.builder?.elapsedTime ?? 0,
                        showSubseconds: context.cadence == .live
                    )
                    .foregroundStyle(.yellow)
                    
                    Label {
                        Text(
                            Measurement(
                                value: workoutManager.activeEnergy,
                                unit: UnitEnergy.kilocalories
                            )
                            .formatted(
                                .measurement(
                                    width: .abbreviated,
                                    usage: .workout,
                                    numberFormatStyle: .number.precision(.fractionLength(0))
                                )
                            )
                        )
                    } icon: {
                        Image(systemName: "bolt.circle.fill")
                    }
                    
                    Label {
                        Text(
                            workoutManager.heartRate
                                .formatted(
                                    .number.precision(.fractionLength(0))
                                )
                            + " bpm"
                        )
                    } icon: {
                        Image(systemName: "heart.circle.fill")
                    }
                    .foregroundStyle(workoutManager.heartRate.zoneColor())
                    
                    if workoutManager.isOutdoors {
                        Label {
                            Text(
                                Measurement(
                                    value: workoutManager.distance,
                                    unit: UnitLength.meters
                                )
                                .formatted(
                                    .measurement(
                                        width: .abbreviated,
                                        usage: .road,
                                    )
                                )
                            )
                        } icon: {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                    }
                }
                .font(.title2.monospacedDigit().lowercaseSmallCaps())
                .frame(maxWidth: .infinity, alignment: .leading)
                .scenePadding()
                .padding(.top, 20)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MetricsView()
        .environment(WorkoutManager())
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date
    
    init(from startDate: Date) {
        self.startDate = startDate
    }
    
    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(
            from: self.startDate,
            by: mode == .lowFrequency ? 1.0 : 1.0 / 30.0
        ).entries(
            from: startDate,
            mode: mode
        )
    }
}
