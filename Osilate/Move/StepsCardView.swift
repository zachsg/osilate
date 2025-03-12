//
//  StepsCardView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import HealthKit
import SwiftUI

struct StepsCardView: View {
    @Environment(HealthController.self) private var healthController
    
    let completed: Double
    let timeFrame: OTimePeriod
    
    var steps: Int {
        switch timeFrame {
        case .day:
            healthController.stepCountToday
        case .week:
            healthController.stepCountWeek
        case .month:
            healthController.stepCountMonth
        }
    }
    
    var distance: Double {
        switch timeFrame {
        case .day:
            healthController.distanceToday.rounded(toPlaces: 1)
        case .week:
            healthController.distanceWeek.rounded(toPlaces: 1)
        case .month:
            healthController.distanceMonth.rounded(toPlaces: 1)
        }
    }
    
    var distanceUnit: String {
        let unit = UnitLength(forLocale: .current)
        
        return if unit == UnitLength.feet {
            "miles"
        } else {
            "km"
        }
    }
    
    var body: some View {
        VStack {
            switch timeFrame {
            case .day:
                MoveDayStepsBarChart()
                    .task {
                        healthController.getStepCountDayByHour()
                    }
            case .week:
                MoveWeekStepsBarChart()
                    .task {
                        healthController.getStepCountWeekByDay()
                    }
            case .month:
                MoveMonthStepsBarChart()
                    .task {
                        healthController.getStepCountMonthByDay()
                    }
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(steps, format: .number)
                            .font(.title.bold())
                        
                        Text("steps")
                            .font(.caption)
                            .foregroundStyle(.accent)
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(distance, format: .number)
                            .font(.headline.bold())
                    
                        Text(distanceUnit)
                            .font(.caption)
                            .foregroundStyle(.accent)
                    }
                }
                
                Spacer()
            }
            .foregroundStyle(.move)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(.move, lineWidth: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .trim(from: completed, to: 1)
                        .stroke(.background, lineWidth: 6)
                        .rotationEffect(.degrees(180))
                )
        )
        .padding()
    }
}

#Preview {
    let healthController = HealthController()
    
    healthController.stepCountWeek = 50000
    healthController.distanceWeek = 12.5
    
    let today: Date = .now
    for i in 0...6 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.stepCountWeekByDay[date] = Int.random(in: 0...15000)
        }
    }
    
    return StepsCardView(completed: 0.33, timeFrame: .week)
        .environment(healthController)
}
