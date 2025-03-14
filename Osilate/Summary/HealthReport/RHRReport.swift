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
    
    @State private var isExpanded = false
    
    var top: Int {
        let top = healthController.rhrRangeTop > healthController.rhrMeasuredTop ? healthController.rhrRangeTop : healthController.rhrMeasuredTop
        
        return top + 1
    }
    
    var bottom: Int {
        let bottom = healthController.rhrRangeBottom < healthController.rhrMeasuredBottom ? healthController.rhrRangeBottom : healthController.rhrMeasuredBottom
        
        return bottom - 1
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
                    
                    RuleMark(y: .value("Top", healthController.rhrRangeTop))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", healthController.rhrRangeBottom))
                        .foregroundStyle(.accent.opacity(0.5))
                }
                .chartXAxis(isExpanded ? .automatic : .hidden)
                .chartYAxis(isExpanded ? .automatic : .hidden)
                .chartYScale(domain: bottom >= top ? 0...1 : bottom...top)
                .frame(height: isExpanded ? 256 : 48)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: "\(rhrTitle) (RHR)", systemImage: rhrSystemImage)
        } footer: {
            isExpanded ? Text("Units: Beats per minute (BPM).") : nil
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
    
    return RHRReport()
        .environment(healthController)
}
