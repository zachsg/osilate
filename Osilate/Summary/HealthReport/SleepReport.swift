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
    
    @State private var isExpanded = false
    
    var top: Double {
        let top = healthController.sleepRangeTop > healthController.sleepMeasuredTop ? healthController.sleepRangeTop : healthController.sleepMeasuredTop
        
        return top + 1
    }
    
    var bottom: Double {
        let bottom = healthController.sleepRangeBottom < healthController.sleepMeasuredBottom ? healthController.sleepRangeBottom : healthController.sleepMeasuredBottom
        
        return bottom - 1
    }
    
    var body: some View {
        Section {
            if healthController.sleepByDayLoading {
                ProgressView()
            } else {
                Chart {
                    ForEach(healthController.sleepByDay.sorted { $0.key < $1.key }, id: \.key) { date, hours in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("Hours", hours)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", healthController.sleepRangeTop))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", healthController.sleepRangeBottom))
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
            HeaderLabel(title: "\(sleepTitle)", systemImage: sleepSystemImage)
        } footer: {
            isExpanded ? Text("Units: Measured in hours.") : nil
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
    
    return SleepReport()
        .environment(healthController)
}
