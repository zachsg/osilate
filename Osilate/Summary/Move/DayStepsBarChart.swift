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
        Chart {
            ForEach(healthController.stepCountHourly.sorted { $0.key < $1.key }, id: \.key) { hour, steps in
                BarMark(
                    x: .value("Hour", hour),
                    y: .value("Steps", steps)
                )
                .cornerRadius(2)
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    for i in 0...12 {
        healthController.stepCountHourly[i] = Int.random(in: 0...20000)
    }
    
    return DayStepsBarChart()
        .environment(healthController)
}
