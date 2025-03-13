//
//  MoveMonthStepsBarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct MoveMonthStepsBarChart: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal: Int = dailyMoveGoalDefault
    
    var averageStepsPerDay: Int {
        var cumulative = 0
        var days = 0
        for (_, steps) in healthController.stepCountMonthByDay {
            days += 1
            cumulative += steps
        }
        
        return days == 0 ? 0 : cumulative / days
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Text("Daily average:")
                    Text(averageStepsPerDay, format: .number)
                        .foregroundStyle(.move)
                    Text("steps")
                }
                .font(.subheadline.bold())
                .padding(.bottom, 2)
                
                Chart {
                    ForEach(healthController.stepCountMonthByDay.sorted { $0.key < $1.key }, id: \.key) { date, steps in
                        BarMark(
                            x: .value("Day", date),
                            y: .value("Steps", steps)
                        )
                        .foregroundStyle(steps >= dailyMoveGoal ? .move : .move.opacity(0.5))
                        .cornerRadius(50)
                    }
                    
                    RuleMark(y: .value("Goal", dailyMoveGoal))
                        .foregroundStyle(.move)
                }
            }
            
            if healthController.stepsMonthByDayLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    for i in 0...30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: .now)
        if let date {
            healthController.stepCountMonthByDay[date] = Int.random(in: 0...15000)
        }
    }
    
    return MoveMonthStepsBarChart()
        .environment(healthController)
}
