//
//  BodyTempReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct BodyTempReport: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var bodyTempHigh: Double
    @Binding var bodyTempLow: Double
    @Binding var bodyTempStatus: BodyMetricStatus?
    
    @State private var lowestTemp = 200.0
    @State private var highestTemp = 0.0
    @State private var isExpanded = false
    
    var bottomRange: Double {
        let bottom = lowestTemp > bodyTempLow ? bodyTempLow : lowestTemp
        return bottom - 0.5
    }
    
    var topRange: Double {
        let top = highestTemp > bodyTempHigh ? highestTemp : bodyTempHigh
        return top + 0.5
    }
    
    var units: String {
        let metricOrImperial = UnitLength(forLocale: .current)
        return metricOrImperial == .feet ? "fahrenheit" : "celsius"
    }
    
    var body: some View {
        Section {
            if healthController.bodyTempByDayLoading {
                ProgressView()
                    .padding(.horizontal)
            } else {
                Chart {
                    ForEach(healthController.bodyTempByDay.sorted { $0.key < $1.key }, id: \.key) { date, temp in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("Temp", temp)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", bodyTempHigh))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", bodyTempLow))
                        .foregroundStyle(.accent.opacity(0.5))
                }
                .chartXAxis(isExpanded ? .automatic : .hidden)
                .chartYAxis(isExpanded ? .automatic : .hidden)
                .chartYScale(domain: bodyTempLow < bodyTempHigh ? bottomRange...topRange : 95...98)
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
            HeaderLabel(title: bodyTempTitle, systemImage: bodyTempStatus == .normal ? bodyTempNormalSystemImage : bodyTempStatus == .low ? bodyTempLowSystemImage : bodyTempHighSystemImage)
        } footer: {
            isExpanded ? Text("Units: Degrees \(units).") : nil
        }
        .task {
            await tryAgain()
        }
    }
    
    @MainActor
    func tryAgain() async {
        while healthController.bodyTempByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        calculateBodyTempRange()
        calculateBodyTempStatus()
    }
    
    private func calculateBodyTempRange() {
        var average = 0.0
        
        for (_, temp) in healthController.bodyTempByDay {
            average += temp
            
            if temp < lowestTemp {
                lowestTemp = temp
            }
            
            if temp > highestTemp {
                highestTemp = temp
            }
        }
        
        average /= Double(healthController.bodyTempByDay.count)
        
        bodyTempLow = average - 1
        bodyTempHigh = average + 1
    }
    
    private func calculateBodyTempStatus() {
        bodyTempStatus = if healthController.bodyTempToday < bodyTempLow {
            .low
        } else if healthController.bodyTempToday > bodyTempHigh {
            .high
        } else {
            .normal
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.bodyTempToday = 98
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.bodyTempByDay[date] = Double(Int.random(in: 94...101))
        }
    }
    
    return BodyTempReport(bodyTempHigh: .constant(101), bodyTempLow: .constant(95), bodyTempStatus: .constant(.normal))
        .environment(healthController)
}
