//
//  SleepReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/13/25.
//

import Charts
import SwiftUI

struct SleepReport: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var sleepHigh: Double
    @Binding var sleepLow: Double
    @Binding var sleepStatus: BodyMetricStatus?
    
    @State private var lowestSleep = 24.0
    @State private var highestSleep = 0.0
    @State private var isExpanded = false
    
    var bottomRange: Double {
        let bottom = lowestSleep > sleepLow ? sleepLow : lowestSleep
        return bottom - 1
    }
    
    var topRange: Double {
        let top = highestSleep > sleepHigh ? highestSleep : sleepHigh
        return top + 1
    }
    
    var body: some View {
        Section {
            if healthController.sleepByDayLoading {
                ProgressView()
                    .padding(.horizontal)
            } else {
                Chart {
                    ForEach(healthController.sleepByDay.sorted { $0.key < $1.key }, id: \.key) { date, hours in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("Hours", hours)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", sleepHigh))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", sleepLow))
                        .foregroundStyle(.accent.opacity(0.5))
                }
                .chartXAxis(isExpanded ? .automatic : .hidden)
                .chartYAxis(isExpanded ? .automatic : .hidden)
                .chartYScale(domain: sleepLow < sleepHigh ? bottomRange...topRange : 20...150)
                .frame(height: isExpanded ? 256 : 40)
                .padding(.horizontal, 4)
                .padding(.vertical, isExpanded ? 4 : 0)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: "\(sleepTitle)", systemImage: sleepSystemImage)
        } footer: {
            isExpanded ? Text("Units: Measured in hours.") : nil
        }
        .task {
            await tryAgain()
        }
    }
    
    @MainActor
    func tryAgain() async {
        while healthController.sleepByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        calculateSleepRange()
        calculateSleepStatus()
    }
    
    private func calculateSleepRange() {
        var average = 0.0
        
        for (_, hours) in healthController.sleepByDay {
            average += hours
            
            if hours < lowestSleep {
                lowestSleep = hours
            }
            
            if hours > highestSleep {
                highestSleep = hours
            }
        }
        
        average /= Double(healthController.sleepByDay.count)
        
        sleepLow = average - 1
        sleepHigh = average + 1
    }
    
    private func calculateSleepStatus() {
        sleepStatus = if healthController.sleepToday < sleepLow {
            .low
        } else if healthController.sleepToday > sleepHigh {
            .optimal
        } else {
            .normal
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.sleepToday = 8
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.sleepByDay[date] = Double(Int.random(in: 5...9))
        }
    }
    
    return SleepReport(sleepHigh: .constant(8.5), sleepLow: .constant(6.5), sleepStatus: .constant(.normal))
        .environment(healthController)
}
