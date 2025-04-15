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
                .foregroundStyle(zoneColor())
                
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
            .font(.title2.monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
            .scenePadding()
            .padding(.top, 40)
        }
    }
    
    private func zoneColor() -> Color {
        let zone2Range = Double(hrZone(.two, at: .start))...Double(hrZone(.two, at: .end))
        let zone3Range = Double(hrZone(.three, at: .start))...Double(hrZone(.three, at: .end))
        let zone4Range = Double(hrZone(.four, at: .start))...Double(hrZone(.four, at: .end))
        let zone5Start = Double(hrZone(.five, at: .start))
        
        switch workoutManager.heartRate {
            case zone2Range:
            return .yellow
        case zone3Range:
            return .orange
            case zone4Range:
            return .red
        case let x where x >= zone5Start:
            return .purple
        default:
            return .green
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
