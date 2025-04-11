//
//  VO2Chart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct VO2Chart: View {
    @Environment(HealthController.self) private var healthController

    var averageVO2: Double {
        var sum = 0.0
        var count = 0

        for (_, vO2) in healthController.cardioFitnessByDay {
            sum += vO2
            count += 1
        }

        sum /= Double(count > 0 ? count : 1)

        return (sum * 10).rounded() / 10
    }

    var lowHigh: (low: Double, high: Double) {
        var low = 100.0
        var high = 0.0

        for (_, vO2) in healthController.cardioFitnessByDay {
            if vO2 > high {
                high = vO2
            }

            if vO2 < low {
                low = vO2
            }
        }

        low -= 1
        high += 1

        if low > high {
            return (0, 0)
        } else {
            return (low, high)
        }
    }

    var averageZone2: Int {
        var sum = 0.0
        var count = 0

        for (_, zone2) in healthController.zone2ByDay {
            sum += Double(zone2)
            count += 1
        }
        
        sum /= Double(count > 0 ? count : 1)

        return Int((sum * 10).rounded() / 10)
    }

    var lowHighZone2: (low: Int, high: Int) {
        var low = 120
        var high = 0

        for (_, rhr) in healthController.zone2ByDay {
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
                    Text(averageVO2, format: .number)
                        .fontWeight(.bold)
                    Text(" \(vO2Units)")
                        .font(.caption)
                    Text(")")
                }
            ) {
                ZStack {
                    Chart {
                        ForEach(healthController.cardioFitnessByDay.sorted { $0.key < $1.key }, id: \.key) { date, vO2 in
                            LineMark(
                                x: .value("Day", date),
                                y: .value(vO2Units, vO2)
                            )
                            .lineStyle(.init(lineWidth: 3, lineCap: .round))
                            .foregroundStyle(.sweat)
                        }
                        
                        RuleMark(y: .value("Average", averageVO2))
                            .foregroundStyle(.accent.opacity(0.7))
                    }
                    .chartYScale(domain: lowHigh.low...lowHigh.high)
                    .chartForegroundStyleScale([vO2Units: .sweat])
                    .chartLegend(.visible)
                    
                    if healthController.cardioFitnessLoading {
                        ProgressView()
                    }
                }

                ZStack {
                    Chart {
                        ForEach(healthController.zone2ByDay.sorted { $0.key < $1.key }, id: \.key) { date, minutes in
                            BarMark(
                                x: .value("Day", date),
                                y: .value("Minutes", minutes)
                            )
                            .foregroundStyle(.sweat)
                        }
                        
                        RuleMark(y: .value("Average", averageZone2))
                            .foregroundStyle(.accent.opacity(0.7))
                    }
                    .chartYScale(domain: lowHighZone2.low...lowHighZone2.high)
                    .chartForegroundStyleScale(["Zone 2+ HR minutes": .sweat])
                    .chartLegend(.visible)
                    
                    if healthController.zone2ByDayLoading {
                        ProgressView()
                    }
                }

            }
            .padding()

            Section {
                Text("Your \(vO2Units) (also known as cardio fitness) is the maximum amount of oxygen your body can consume during exercise. A higher \(vO2Units) is an indicator of better cardiovascular fitness and endurance.")
                    .foregroundStyle(.secondary)
            }
            .padding([.leading, .trailing, .bottom])
        }
        .navigationTitle("Cardio Fitness Trend")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let healthController = HealthController()

    healthController.cardioFitnessAverage = 43

    let today: Date = .now
    for i in 0...60 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.cardioFitnessByDay[date] = Double.random(in: 40...45)
        }
    }

    for i in 0...60 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.zone2ByDay[date] = Int.random(in: 0...50)
        }
    }

    return VO2Chart()
        .environment(healthController)
}
