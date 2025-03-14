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
    
    @Binding var rangeTop: Double
    @Binding var rangeBottom: Double
    @Binding var measuredTop: Double
    @Binding var measuredBottom: Double
    @Binding var status: BodyMetricStatus?
    
    @State private var isExpanded = false
    
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
            HeaderLabel(title: "\(oxygenTitle) (O2)", systemImage: oxygenSystemImage)
        } footer: {
            isExpanded ? Text("Units: Percentage oxygen in blood (SpO2).") : nil
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
    
    return OxygenReport(rangeTop: .constant(99), rangeBottom: .constant(97), measuredTop: .constant(98.5), measuredBottom: .constant(96.5), status: .constant(.normal))
        .environment(healthController)
}
