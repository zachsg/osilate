//
//  RHRChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct RHRChart: View {
    @Environment(HealthController.self) private var healthController

    var averageRhr: Int {
        var sum = 0
        var count = 0

        for (_, rhr) in healthController.rhrByDay {
            sum += rhr
            count += 1
        }

        let average = Double(sum) / Double(count > 0 ? count : 1)

        return Int((average * 100).rounded() / 100)
    }

    var lowHigh: (low: Int, high: Int) {
        var low = 120
        var high = 0

        for (_, rhr) in healthController.rhrByDay {
            if rhr > high {
                high = rhr
            }

            if rhr < low {
                low = rhr
            }
        }

        low -= 4
        high += 4

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
                Text(averageRhr, format: .number)
                    .fontWeight(.bold)
                Text(" \(heartUnits)")
                    .font(.caption)
                Text(")")
            }
            ) {
                ZStack {
                    Chart {
                        ForEach(healthController.rhrByDay.sorted { $0.key < $1.key }, id: \.key) { date, rhr in
                            LineMark(
                                x: .value("Day", date),
                                y: .value(heartUnits, rhr)
                            )
                            .lineStyle(.init(lineWidth: 3, lineCap: .round))
                            .foregroundStyle(.sweat)
                        }
                        
                        RuleMark(y: .value("Average", averageRhr))
                            .foregroundStyle(.accent.opacity(0.7))
                    }
                    .chartYScale(domain: lowHigh.low...lowHigh.high)
                    
                    if healthController.rhrLoading {
                        ProgressView()
                    }
                }
            }
            .padding()

            Section {
                Text("Your resting hear rate is the average number of times your heart beats per minute while you are inactive or at rest. Lower resting heart rates are generally a sign of higher cardiovascular fitness.")
                    .foregroundStyle(.secondary)
            }
            .padding([.leading, .trailing, .bottom])
        }
        .navigationTitle("Resting Heart Rate Trend")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let healthController = HealthController()

    healthController.rhrAverage = 63

    let today: Date = .now
    for i in 0...30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.rhrByDay[date] = Int.random(in: 60...70)
        }
    }

    return RHRChart()
        .environment(healthController)
}
