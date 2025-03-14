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
            HeaderLabel(title: "\(hrvTitle) (HRV)", systemImage: hrvSystemImage)
        } footer: {
            isExpanded ? Text("Units: Measured in ms using SDNN method.") : nil
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
    
    return HRVReport(rangeTop: .constant(99), rangeBottom: .constant(97), measuredTop: .constant(100), measuredBottom: .constant(97.5), status: .constant(.normal))
        .environment(healthController)
}
