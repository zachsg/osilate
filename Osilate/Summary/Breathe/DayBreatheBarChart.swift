//
//  DayBreatheBarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/14/25.
//

import Charts
import SwiftUI

struct DayBreatheBarChart: View {
    @Environment(HealthController.self) private var healthController
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(healthController.mindfulMinutesDayByHour.sorted { $0.key < $1.key }, id: \.key) { hour, minutes in
                    BarMark(
                        x: .value("Hour", hour),
                        y: .value("Minutes", minutes)
                    )
                    .cornerRadius(2)
                    .foregroundStyle(.breathe)
                }
            }
            
            if healthController.mindfulMinutesDayByHourLoading {
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
            healthController.mindfulMinutesDayByHour[date] = Int.random(in: 0...30)
        }
    }
    
    return DayBreatheBarChart()
        .environment(healthController)
}
