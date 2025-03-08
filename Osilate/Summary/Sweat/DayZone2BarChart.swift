//
//  DayZone2BarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct DayZone2BarChart: View {
    @Environment(HealthController.self) private var healthController
    
    var body: some View {
        Chart {
            ForEach(healthController.zone2Hourly.sorted { $0.key < $1.key }, id: \.key) { hour, minutes in
                BarMark(
                    x: .value("Hour", hour),
                    y: .value("Minutes", minutes)
                )
                .cornerRadius(2)
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    for i in 0...12 {
        healthController.zone2Hourly[i] = Int.random(in: 0...45)
    }
    
    return DayZone2BarChart()
        .environment(healthController)
}
