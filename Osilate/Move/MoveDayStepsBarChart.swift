//
//  DayStepsBarChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct MoveDayStepsBarChart: View {
    @Environment(HealthController.self) private var healthController
    
    var best: (date: Date, steps: Int) {
        var count = 0
        var bestDate: Date = .now
        
        for (date, steps) in healthController.stepCountDayByHour {
            if steps > count {
                count = steps
                bestDate = date
            }
        }
        
        return (bestDate, count)
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Text("Most active from \(hourFormatted(date: best.date)): \(best.steps) steps")
                }
                .font(.subheadline.bold())
                .padding(.bottom, 2)
                
                Chart {
                    ForEach(healthController.stepCountDayByHour.sorted { $0.key < $1.key }, id: \.key) { hour, steps in
                        BarMark(
                            x: .value("Hour", hour),
                            y: .value("Steps", steps)
                        )
                        .foregroundStyle(.move)
                        .cornerRadius(50)
                    }
                }
                .frame(height: 100)
            }
            
            if healthController.stepsDayByHourLoading {
                ProgressView()
            }
        }
    }
    
    private func hourFormatted(date: Date) -> String {
        let endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date)
        
        return if let endDate {
            "\(date.hour()) - \(endDate.hour())"
        } else {
            date.hour()
        }
    }
    
    private func loading() -> Bool {
        healthController.stepCountDayByHour.isEmpty && (healthController.stepsDayByHourLoading || healthController.stepsWeekByDayLoading)
    }
}

#Preview {
    let healthController = HealthController()
    
    let calendar = Calendar.current
    let currentHour = calendar.dateComponents([.hour], from: .now)
    for i in 0...currentHour.hour! {
        let date = calendar.date(byAdding: .hour, value: -i, to: .now)
        if let date {
            healthController.stepCountDayByHour[date] = Int.random(in: 0...2000)
        }
    }
    
    return MoveDayStepsBarChart()
        .environment(healthController)
}
