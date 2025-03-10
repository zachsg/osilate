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
    
    let bodyTempRange: (low: Double, high: Double)
    let bodyTempHealthyRange: (low: Double, high: Double)
    let todayTempStatus: BodyTempStatus
    
    @State private var isExpanded = false
    
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
                    
                    RuleMark(y: .value("Top", bodyTempHealthyRange.high))
                        .foregroundStyle(.accent.opacity(0.7))
                    
                    RuleMark(y: .value("Bottom", bodyTempHealthyRange.low))
                        .foregroundStyle(.accent.opacity(0.7))
                }
                .chartYScale(domain: bodyTempRange.low < bodyTempRange.high ? bodyTempRange.low...bodyTempRange.high : 95...98)
                .frame(height: isExpanded ? 320 : 128)
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        } header: {
            HeaderLabel(title: bodyTempTitle, systemImage: todayTempStatus == .normal ? bodyTempNormalSystemImage : todayTempStatus == .low ? bodyTempLowSystemImage : bodyTempHighSystemImage)
        } footer: {
            // TODO: Fix to work with current locale vs just imperial.
            Text("Units: Degrees fahrenheit.")
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    let bodyTempHealthRange = (97.0, 98.0)
    let bodyTempRange = (95.0, 99.0)
    
    return BodyTempReport(bodyTempRange: bodyTempRange, bodyTempHealthyRange: bodyTempHealthRange, todayTempStatus: .normal)
        .environment(healthController)
}
