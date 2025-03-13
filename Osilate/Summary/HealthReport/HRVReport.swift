//
//  HRVReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/12/25.
//

import Charts
import SwiftUI

struct HRVReport: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var hrvHigh: Double
    @Binding var hrvLow: Double
    @Binding var hrvStatus: BodyMetricStatus?
    
    @State private var lowestHrv = 400.0
    @State private var highestHrv = 0.0
    @State private var isExpanded = false
    
    var bottomRange: Double {
        let bottom = lowestHrv > hrvLow ? hrvLow : lowestHrv
        return bottom - 1
    }
    
    var topRange: Double {
        let top = highestHrv > hrvHigh ? highestHrv : hrvHigh
        return top + 1
    }
    
    var body: some View {
        Section {
            if healthController.hrvByDayLoading {
                ProgressView()
            } else {
                Chart {
                    ForEach(healthController.hrvByDay.sorted { $0.key < $1.key }, id: \.key) { date, hrv in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("HRV", hrv)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", hrvHigh))
                        .foregroundStyle(.accent.opacity(0.7))
                    
                    RuleMark(y: .value("Bottom", hrvLow))
                        .foregroundStyle(.accent.opacity(0.7))
                }
                .chartYScale(domain: hrvLow < hrvHigh ? bottomRange...topRange : 20...150)
                .frame(height: isExpanded ? 320 : 128)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: "\(hrvTitle) (HRV)", systemImage: hrvSystemImage)
        } footer: {
            Text("Units: Measured in ms using SDNN method.")
        }
        .task {
            await tryAgain()
        }
    }
    
    @MainActor
    func tryAgain() async {
        while healthController.hrvByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        calculateHrvRange()
        calculateHrvStatus()
    }
    
    private func calculateHrvRange() {
        var average = 0.0
        
        for (_, hrv) in healthController.hrvByDay {
            average += hrv
            
            if hrv < lowestHrv {
                lowestHrv = hrv
            }
            
            if hrv > highestHrv {
                highestHrv = hrv
            }
        }
        
        average /= Double(healthController.hrvByDay.count)
        
        hrvLow = average - 10
        hrvHigh = average + 10
    }
    
    private func calculateHrvStatus() {
        hrvStatus = if healthController.hrvToday < hrvLow {
            .low
        } else if healthController.hrvToday > hrvHigh {
            .optimal
        } else {
            .normal
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.hrvToday = 52
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.hrvByDay[date] = Double(Int.random(in: 30...71))
        }
    }
    
    return HRVReport(hrvHigh: .constant(65), hrvLow: .constant(49), hrvStatus: .constant(.normal))
        .environment(healthController)
}
