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
    
    @Binding var rangeTop: Int
    @Binding var rangeBottom: Int
    @Binding var measuredTop: Int
    @Binding var measuredBottom: Int
    @Binding var status: BodyMetricStatus?
    
    @State private var isExpanded = false
    
    var top: Int {
        let top = rangeTop > measuredTop ? rangeTop : measuredTop
        
        return top + 1
    }
    
    var bottom: Int {
        let bottom = rangeBottom < measuredBottom ? rangeBottom : measuredBottom
        
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
    
    return RHRReport(rangeTop: .constant(70), rangeBottom: .constant(60), measuredTop: .constant(63), measuredBottom: .constant(60), status: .constant(.normal))
        .environment(healthController)
}
