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
    
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal: Int = dailyMoveGoalDefault
    
    @State private var dayExpanded = true
    @State private var weekExpanded = false
    @State private var monthExpanded = false
    
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
            ScrollView {
                VStack {
                    StepsCardView(completed: completedMonth, timeFrame: .month, isExpanded: $monthExpanded)
                    StepsCardView(completed: completedWeek, timeFrame: .week, isExpanded: $weekExpanded)
                    StepsCardView(completed: completedDay, timeFrame: .day, isExpanded: $dayExpanded)
                }
            }
            .navigationTitle(moveString)
        }
        .onAppear {
            refresh()
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
    healthController.stepCountToday = 5000
    healthController.stepCountWeek = 75000
    healthController.stepCountMonth = 250000
    
    return MoveView()
        .environment(healthController)
}
