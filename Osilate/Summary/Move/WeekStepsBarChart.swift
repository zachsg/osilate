//
//  WeekStepsBarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct WeekStepsBarChart: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal: Int = dailyMoveGoalDefault
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(healthController.stepCountWeekByDay.sorted { $0.key < $1.key }, id: \.key) { date, steps in
                    BarMark(
                        x: .value("Day", date.weekDay()),
                        y: .value("Steps", steps)
                    )
                    .foregroundStyle(steps >= dailyMoveGoal ? .move : .accent)
                    .cornerRadius(2)
                }
                
                RuleMark(y: .value("Goal", dailyMoveGoal))
                    .foregroundStyle(.move.opacity(0.4))
            }
            
            if healthController.stepsWeekByDayLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    let today: Date = .now
    for i in 0...6 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.stepCountWeekByDay[date] = Int.random(in: 0...20000)
        }
    }
    
    return WeekStepsBarChart()
        .environment(healthController)
}
