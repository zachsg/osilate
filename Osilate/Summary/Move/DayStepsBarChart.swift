//
//  DayStepsBarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct DayStepsBarChart: View {
    @Environment(HealthController.self) private var healthController
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(healthController.stepCountDayByHour.sorted { $0.key < $1.key }, id: \.key) { hour, steps in
                    BarMark(
                        x: .value("Hour", hour),
                        y: .value("Steps", steps)
                    )
                    .cornerRadius(2)
                }
            }
            
            if healthController.stepsDayByHourLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    let today: Date = .now
    for i in 0...5 {
        let date = Calendar.current.date(byAdding: .hour, value: -i, to: today)
        if let date {
            healthController.stepCountDayByHour[date] = Int.random(in: 100...2000)
        }
    }
    
    return DayStepsBarChart()
        .environment(healthController)
}
