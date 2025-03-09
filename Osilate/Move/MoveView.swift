//
//  MoveView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct MoveView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal: Int = dailyMoveGoalDefault
    
    @State private var animationAmount = 0.0
    @State private var dayExpanded = true
    @State private var weekExpanded = false
    @State private var monthExpanded = false
    
    var movePercent: Double {
        if showToday {
            (Double(healthController.stepCountToday) / Double(dailyMoveGoal)).rounded(toPlaces: 2)
        } else {
            (Double(healthController.stepCountWeek) / Double(dailyMoveGoal * 7)).rounded(toPlaces: 2)
        }
    }
    
    var steps: Int {
        if showToday {
            healthController.stepCountToday
        } else {
            healthController.stepCountWeek
        }
    }
    
    var distance: Double {
        if showToday {
            healthController.distanceToday
        } else {
            healthController.distanceWeek
        }
    }
    
    var distanceUnit: String {
        let unit = UnitLength(forLocale: .current)
        
        return if unit == UnitLength.feet {
            "miles"
        } else {
            "km"
        }
    }
    
    var completedDay: Double {
        let completed = Double(healthController.stepCountToday) / Double(dailyMoveGoal)
        return completed > 1 ? 1 : completed
    }
    
    var completedWeek: Double {
        let completed = Double(healthController.stepCountWeek) / Double(dailyMoveGoal * 7)
        return completed > 1 ? 1 : completed
    }
    
    var completedMonth: Double {
        let completed = Double(healthController.stepCountMonth) / Double(dailyMoveGoal * 30)
        return completed > 1 ? 1 : completed
    }
    
    var body: some View {
        NavigationStack {
            List {
                ActivityRingAndStats(percent: movePercent, color: .move) {
                    HStack(spacing: 2) {
                        Text(steps, format: .thousandsAbbr)
                            .font(.title.bold())
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("steps")
                            HStack(spacing: 4) {
                                Text("of")
                                Text(showToday ? dailyMoveGoal : dailyMoveGoal * 7, format: .thousandsAbbr)
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(distance, format: .number)
                            .font(.title2.bold())
                        Text(distanceUnit)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    StepsCardView(completed: completedMonth, timeFrame: .month, isExpanded: $monthExpanded)
                    StepsCardView(completed: completedWeek, timeFrame: .week, isExpanded: $weekExpanded)
                    StepsCardView(completed: completedDay, timeFrame: .day, isExpanded: $dayExpanded)
                }
            }
            .refreshable {
                refresh()
            }
            .navigationTitle(moveString)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                refresh()
            }
        }
        .onChange(of: dayExpanded) { old, new in
            if new {
                withAnimation {
                    weekExpanded = false
                    monthExpanded = false
                }
            }
        }
        .onChange(of: weekExpanded) { old, new in
            if new {
                withAnimation {
                    dayExpanded = false
                    monthExpanded = false
                }
            }
        }
        .onChange(of: monthExpanded) { old, new in
            if new {
                withAnimation {
                    dayExpanded = false
                    weekExpanded = false
                }
            }
        }
    }
    
    private func refresh() {
        healthController.getStepCountFor(.day)
        healthController.getStepCountFor(.week)
        healthController.getStepCountFor(.month)
        
        healthController.getDistanceFor(.day)
        healthController.getDistanceFor(.week)
        healthController.getDistanceFor(.month)

        healthController.getStepCountDayByHour()
        healthController.getStepCountWeekByDay()
        healthController.getStepCountMonthByDay()
    }
}

#Preview {
    let healthController = HealthController()
    healthController.stepCountToday = 5500
    healthController.stepCountWeek = 75000
    healthController.stepCountMonth = 250000
    healthController.distanceToday = 5
    healthController.distanceWeek = 25
    
    return MoveView()
        .environment(healthController)
}
