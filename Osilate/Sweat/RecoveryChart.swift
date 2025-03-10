//
//  RecoveryChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct RecoveryChart: View {
    @Environment(HealthController.self) private var healthController

    var averageRecovery: Int {
        var sum = 0
        var count = 0

        for (_, hr) in healthController.recoveryByDay {
            sum += hr
            count += 1
        }

        let average = Double(sum) / Double(count > 0 ? count : 1)

        return Int((average * 100).rounded() / 100)
    }

    var lowHigh: (low: Int, high: Int) {
        var low = 120
        var high = 0

        for (_, hr) in healthController.recoveryByDay {
            if hr > high {
                high = hr
            }

            if hr < low {
                low = hr
            }
        }

        low -= 2
        high += 2

        if low > high {
            return (0, 0)
        } else {
            return (low, high)
        }
    }

    var body: some View {
        VStack {
            GroupBox(label:
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("Past 60 Days (avg: ")
                Text(averageRecovery, format: .number)
                    .fontWeight(.bold)
                Text(" \(heartUnits)")
                    .font(.caption)
                Text(")")
            }
            ) {
                ZStack {
                    Chart {
                        ForEach(healthController.recoveryByDay.sorted { $0.key < $1.key }, id: \.key) { date, hr in
                            LineMark(
                                x: .value("Day", date),
                                y: .value(heartUnits, hr)
                            )
                            .lineStyle(.init(lineWidth: 3, lineCap: .round))
                            .foregroundStyle(.sweat)
                        }
                        
                        RuleMark(y: .value("Average", averageRecovery))
                            .foregroundStyle(.accent.opacity(0.7))
                    }
                    .chartYScale(domain: lowHigh.low...lowHigh.high)
                    
                    if healthController.recoveryLoading {
                        ProgressView()
                    }
                }
            }
            .padding()

            Section {
                Text("As an indicator of your cardiovascular fitness, cardio recovery (also known as heart rate recovery) is a measure of how quickly your heart rate can drop after you reach your peak heart rate during exercise. The higher your cardio recovery the better.")
                    .foregroundStyle(.secondary)
            }
            .padding([.leading, .trailing, .bottom])
        }
        .navigationTitle("Cardio Recovery Trend")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let healthController = HealthController()

    healthController.recoveryAverage = 30

    let today: Date = .now
    for i in 0...30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.recoveryByDay[date] = Int.random(in: 28...33)
        }
    }

    return RecoveryChart()
        .environment(healthController)
}
