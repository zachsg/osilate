//
//  OxygenReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/11/25.
//

import Charts
import SwiftUI

struct OxygenReport: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var oxygenHigh: Double
    @Binding var oxygenLow: Double
    @Binding var oxygenStatus: BodyMetricStatus?
    
    @State private var lowestOxygen = 110.0
    @State private var highestOxygen = 0.0
    @State private var isExpanded = false
    
    var bottomRange: Double {
        let bottom = lowestOxygen > oxygenLow ? oxygenLow : lowestOxygen
        return bottom - 0.2
    }
    
    var topRange: Double {
        let top = highestOxygen > oxygenHigh ? highestOxygen : oxygenHigh
        return top + 0.2
    }
    
    var body: some View {
        Section {
            if healthController.oxygenByDayLoading {
                ProgressView()
            } else {
                Chart {
                    ForEach(healthController.oxygenByDay.sorted { $0.key < $1.key }, id: \.key) { date, ox in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("SpO2", ox)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", oxygenHigh))
                        .foregroundStyle(.accent.opacity(0.7))
                    
                    RuleMark(y: .value("Bottom", oxygenLow))
                        .foregroundStyle(.accent.opacity(0.7))
                }
                .chartYScale(domain: oxygenLow < oxygenHigh ? bottomRange...topRange : 95...100)
                .frame(height: isExpanded ? 320 : 128)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: oxygenTitle, systemImage: oxygenSystemImage)
        } footer: {
            Text("Units: Percentage oxygen in blood (SpO2).")
        }
        .task {
            await tryAgain()
        }
    }
    
    @MainActor
    func tryAgain() async {
        while healthController.oxygenByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        calculateOxygenRange()
        calculateOxygenStatus()
    }
    
    private func calculateOxygenRange() {
        var average = 0.0
        
        for (_, ox) in healthController.oxygenByDay {
            average += ox
            
            if ox < lowestOxygen {
                lowestOxygen = ox
            }
            
            if ox > highestOxygen {
                highestOxygen = ox
            }
        }
        
        average /= Double(healthController.oxygenByDay.count)
        
        oxygenLow = average - 1
        oxygenHigh = average + 1
    }
    
    private func calculateOxygenStatus() {
        oxygenStatus = if healthController.oxygenToday < oxygenLow {
            .low
        } else if healthController.oxygenToday > oxygenHigh {
            .high
        } else {
            .normal
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.oxygenToday = 97.6
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.oxygenByDay[date] = Double(Int.random(in: 95...98))
        }
    }
    
    return OxygenReport(oxygenHigh: .constant(99), oxygenLow: .constant(96), oxygenStatus: .constant(.normal))
        .environment(healthController)
}
