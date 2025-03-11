//
//  RespirationReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/11/25.
//

import Charts
import SwiftUI

struct RespirationReport: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var respirationHigh: Double
    @Binding var respirationLow: Double
    @Binding var respirationStatus: BodyMetricStatus?
    
    @State private var lowestRespiration = 50.0
    @State private var highestRespiration = 0.0
    @State private var isExpanded = false
    
    var bottomRange: Double {
        let bottom = lowestRespiration > respirationLow ? respirationLow : lowestRespiration
        return bottom - 1
    }
    
    var topRange: Double {
        let top = highestRespiration > respirationHigh ? highestRespiration : respirationHigh
        return top + 1
    }
    
    var body: some View {
        Section {
            if healthController.respirationByDayLoading {
                ProgressView()
            } else {
                Chart {
                    ForEach(healthController.respirationByDay.sorted { $0.key < $1.key }, id: \.key) { date, resp in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("Respiration", resp)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", respirationHigh))
                        .foregroundStyle(.accent.opacity(0.7))
                    
                    RuleMark(y: .value("Bottom", respirationLow))
                        .foregroundStyle(.accent.opacity(0.7))
                }
                .chartYScale(domain: respirationLow < respirationHigh ? bottomRange...topRange : 10...30)
                .frame(height: isExpanded ? 320 : 128)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: respirationTitle, systemImage: respirationSystemImage)
        } footer: {
            Text("Units: Breaths per minute (BrPM).")
        }
        .task {
            await tryAgain()
        }
    }
    
    @MainActor
    func tryAgain() async {
        while healthController.respirationByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        calculateRespirationRange()
        calculateRespirationStatus()
    }
    
    private func calculateRespirationRange() {
        var average = 0.0
        
        for (_, temp) in healthController.respirationByDay {
            average += temp
            
            if temp < lowestRespiration {
                lowestRespiration = temp
            }
            
            if temp > highestRespiration {
                highestRespiration = temp
            }
        }
        
        average /= Double(healthController.respirationByDay.count)
        
        respirationLow = average - 1
        respirationHigh = average + 1
    }
    
    private func calculateRespirationStatus() {
        respirationStatus = if healthController.respirationToday < respirationLow {
            .low
        } else if healthController.respirationToday > respirationHigh {
            .high
        } else {
            .normal
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.respirationToday = 14
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.respirationByDay[date] = Double(Int.random(in: 13...18))
        }
    }
    
    return RespirationReport(respirationHigh: .constant(17), respirationLow: .constant(14), respirationStatus: .constant(.normal))
        .environment(healthController)
}
