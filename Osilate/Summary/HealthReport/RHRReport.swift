//
//  RHRReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/11/25.
//

import Charts
import SwiftUI

struct RHRReport: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var rhrHigh: Int
    @Binding var rhrLow: Int
    @Binding var rhrStatus: BodyMetricStatus?
    
    @State private var lowestRhr = 200
    @State private var highestRhr = 0
    @State private var isExpanded = false
    
    var bottomRange: Int {
        let bottom = lowestRhr > rhrLow ? rhrLow : lowestRhr
        return bottom - 1
    }
    
    var topRange: Int {
        let top = highestRhr > rhrHigh ? highestRhr : rhrHigh
        return top + 1
    }
    
    var body: some View {
        Section {
            if healthController.rhrLoading {
                ProgressView()
            } else {
                Chart {
                    ForEach(healthController.rhrByDay.sorted { $0.key < $1.key }, id: \.key) { date, rhr in
                        if date.compare(Date.now.addingTimeInterval(-hourInSeconds * 24 * 14)) == .orderedDescending {
                            LineMark(
                                x: .value("Day", date.day()),
                                y: .value("BPM", rhr)
                            )
                            .lineStyle(.init(lineWidth: 6, lineCap: .round))
                        }
                    }
                    
                    RuleMark(y: .value("Top", rhrHigh))
                        .foregroundStyle(.accent.opacity(0.7))
                    
                    RuleMark(y: .value("Bottom", rhrLow))
                        .foregroundStyle(.accent.opacity(0.7))
                }
                .chartYScale(domain: rhrLow < rhrHigh ? bottomRange...topRange : 65...80)
                .frame(height: isExpanded ? 320 : 128)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: "\(rhrTitle) (RHR)", systemImage: rhrSystemImage)
        } footer: {
            Text("Units: Beats per minute (BPM).")
        }
        .task {
            await tryAgain()
        }
    }
    
    @MainActor
    func tryAgain() async {
        while healthController.rhrLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        calculateRhrRange()
        calculateRhrStatus()
    }
    
    private func calculateRhrRange() {
        var average = 0
        
        for (_, rhr) in healthController.rhrByDay {
            average += rhr
            
            if rhr < lowestRhr {
                lowestRhr = rhr
            }
            
            if rhr > highestRhr {
                highestRhr = rhr
            }
        }
        
        average = Int((Double(average) / Double(healthController.rhrByDay.count)).rounded(toPlaces: 0))
        
        rhrLow = average - 3
        rhrHigh = average + 3
    }
    
    private func calculateRhrStatus() {
        rhrStatus = if healthController.rhrMostRecent < rhrLow {
            .low
        } else if healthController.rhrMostRecent > rhrHigh {
            .high
        } else {
            .normal
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.rhrMostRecent = 75
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.rhrByDay[date] = Int.random(in: 65...80)
        }
    }
    
    return RHRReport(rhrHigh: .constant(78), rhrLow: .constant(60), rhrStatus: .constant(.normal))
        .environment(healthController)
}
