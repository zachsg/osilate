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
        ZStack {
            Chart {
                ForEach(healthController.zone2DayByHour.sorted { $0.key < $1.key }, id: \.key) { hour, minutes in
                    BarMark(
                        x: .value("Hour", hour),
                        y: .value("Minutes", minutes)
                    )
                    .cornerRadius(2)
                    .foregroundStyle(.sweat)
                }
            }
            
            if healthController.zone2DayByHourLoading {
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
            healthController.zone2DayByHour[date] = Int.random(in: 5...60)
        }
    }
    
    return DayZone2BarChart()
        .environment(healthController)
}
