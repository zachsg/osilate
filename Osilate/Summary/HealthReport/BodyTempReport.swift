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
    
    @Binding var rangeTop: Double
    @Binding var rangeBottom: Double
    @Binding var measuredTop: Double
    @Binding var measuredBottom: Double
    @Binding var status: BodyMetricStatus?
    
    @State private var isExpanded = false
    
    var units: String {
        let metricOrImperial = UnitLength(forLocale: .current)
        return metricOrImperial == .feet ? "fahrenheit" : "celsius"
    }
    
    var top: Double {
        let top = rangeTop > measuredTop ? rangeTop : measuredTop
        
        return top + 1
    }
    
    var bottom: Double {
        let bottom = rangeBottom < measuredBottom ? rangeBottom : measuredBottom
        
        return bottom - 1
    }
    
    var body: some View {
        Section {
            if healthController.bodyTempByDayLoading {
                ProgressView()
            } else {
                Chart {
                    ForEach(healthController.bodyTempByDay.sorted { $0.key < $1.key }, id: \.key) { date, temp in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("Temp", temp)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", rangeTop))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", rangeBottom))
                        .foregroundStyle(.accent.opacity(0.5))
                }
                .chartXAxis(isExpanded ? .automatic : .hidden)
                .chartYAxis(isExpanded ? .automatic : .hidden)
                .chartYScale(domain: bottom...top)
                .frame(height: isExpanded ? 256 : 48)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: bodyTempTitle, systemImage: status == .normal ? bodyTempNormalSystemImage : status == .low ? bodyTempLowSystemImage : bodyTempHighSystemImage)
        } footer: {
            isExpanded ? Text("Units: Degrees \(units).") : nil
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
    
    return BodyTempReport(rangeTop: .constant(99), rangeBottom: .constant(97), measuredTop: .constant(100), measuredBottom: .constant(97.5), status: .constant(.normal))
        .environment(healthController)
}
