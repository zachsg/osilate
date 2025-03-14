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
    
    @State private var isExpanded = false
    
    var units: String {
        let metricOrImperial = UnitLength(forLocale: .current)
        return metricOrImperial == .feet ? "fahrenheit" : "celsius"
    }
    
    var top: Double {
        let top = healthController.bodyTempRangeTop > healthController.bodyTempMeasuredTop ? healthController.bodyTempRangeTop : healthController.bodyTempMeasuredTop
        
        return top + 1
    }
    
    var bottom: Double {
        let bottom = healthController.bodyTempRangeBottom < healthController.bodyTempMeasuredBottom ? healthController.bodyTempRangeBottom : healthController.bodyTempMeasuredBottom
        
        return bottom - 1
    }
    
    var body: some View {
        if healthController.bodyTempByDayLoading {
            ProgressView()
        } else {
            VStack(alignment: .leading) {
                Label(bodyTempTitle, systemImage: healthController.bodyTempStatus == .normal ? bodyTempNormalSystemImage : healthController.bodyTempStatus == .low ? bodyTempLowSystemImage : bodyTempHighSystemImage)
                    .font(.footnote.bold())
                
                Chart {
                    ForEach(healthController.bodyTempByDay.sorted { $0.key < $1.key }, id: \.key) { date, temp in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("Temp", temp)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", healthController.bodyTempRangeTop))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", healthController.bodyTempRangeBottom))
                        .foregroundStyle(.accent.opacity(0.5))
                }
                .chartXAxis(isExpanded ? .automatic : .hidden)
                .chartYAxis(isExpanded ? .automatic : .hidden)
                .chartYScale(domain: bottom >= top ? 0...1 : bottom...top)
                .frame(height: isExpanded ? 256 : 48)
                .padding(8)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    Text("Units: Degrees \(units).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.leading)
                }
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.bodyTempByDay[date] = Double(Int.random(in: 94...101))
        }
    }
    
    healthController.bodyTempToday = 98
    healthController.bodyTempRangeTop = 101
    healthController.bodyTempRangeBottom = 94
    healthController.bodyTempMeasuredTop = 100
    healthController.bodyTempMeasuredBottom = 95
    
    return BodyTempReport()
        .environment(healthController)
}
