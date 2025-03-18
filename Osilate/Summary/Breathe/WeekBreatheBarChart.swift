//
//  WeekBreatheBarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/14/25.
//

import Charts
import SwiftUI

struct WeekBreatheBarChart: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal: Int = dailyBreatheGoalDefault
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(healthController.mindfulMinutesWeekByDay.sorted { $0.key < $1.key }, id: \.key) { date, minutes in
                    BarMark(
                        x: .value("Day", date.weekDay()),
                        y: .value("Minutes", minutes)
                    )
                    .foregroundStyle(minutes >= Int((Double(dailyBreatheGoal) / 60).rounded()) ? .breathe : .accent)
                    .cornerRadius(2)
                }
                
                RuleMark(y: .value("Goal", Int((Double(dailyBreatheGoal) / 60).rounded())))
                    .foregroundStyle(.breathe.opacity(0.4))
            }
            
            if healthController.mindfulMinutesWeekByDayLoading {
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
            healthController.mindfulMinutesWeekByDay[date] = Int.random(in: 0...60)
        }
    }
    
    return WeekBreatheBarChart()
        .environment(healthController)
}
