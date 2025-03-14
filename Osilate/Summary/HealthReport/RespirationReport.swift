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
    
    @State private var isExpanded = false
    
    var top: Double {
        let top = healthController.respirationRangeTop > healthController.respirationMeasuredTop ? healthController.respirationRangeTop : healthController.respirationMeasuredTop
        
        return top + 1
    }
    
    var bottom: Double {
        let bottom = healthController.respirationRangeBottom < healthController.respirationMeasuredBottom ? healthController.respirationRangeBottom : healthController.respirationMeasuredBottom
        
        return bottom - 1
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
                    
                    RuleMark(y: .value("Top", healthController.respirationRangeTop))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", healthController.respirationRangeBottom))
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
            HeaderLabel(title: respirationTitle, systemImage: respirationSystemImage)
        } footer: {
            isExpanded ? Text("Units: Breaths per minute (BrPM).") : nil
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
    
    return RespirationReport()
        .environment(healthController)
}
