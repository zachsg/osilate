//
//  WeekZone2BarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct WeekZone2BarChart: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(dailySweatGoalKey) var dailySweatGoal: Int = dailySweatGoalDefault
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(healthController.zone2WeekByDay.sorted { $0.key < $1.key }, id: \.key) { date, minutes in
                    BarMark(
                        x: .value("Day", date.weekDay()),
                        y: .value("Minutes", minutes)
                    )
                    .foregroundStyle(minutes >= dailySweatGoal / 60 ? .sweat : .accent)
                    .cornerRadius(2)
                }
                
                RuleMark(y: .value("Goal", dailySweatGoal / 60))
                    .foregroundStyle(.sweat.opacity(0.4))
            }
            
            if healthController.zone2WeekByDayLoading {
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
            healthController.zone2WeekByDay[date] = Int.random(in: 0...90)
        }
    }
    
    return WeekZone2BarChart()
        .environment(healthController)
}
