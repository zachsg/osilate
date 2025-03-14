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
    
    @State private var isExpanded = false
    
    var top: Double {
        let top = healthController.oxygenRangeTop > healthController.oxygenMeasuredTop ? healthController.oxygenRangeTop : healthController.oxygenMeasuredTop
        
        return top + 1
    }
    
    var bottom: Double {
        let bottom = healthController.oxygenRangeBottom < healthController.oxygenMeasuredBottom ? healthController.oxygenRangeBottom : healthController.oxygenMeasuredBottom
        
        return bottom - 1
    }
    
    var body: some View {
        if healthController.oxygenByDayLoading {
            ProgressView()
        } else {
            VStack(alignment: .leading) {
                Label("\(oxygenTitle) (O2)", systemImage: oxygenSystemImage)
                    .font(.footnote.bold())
                
                Chart {
                    ForEach(healthController.oxygenByDay.sorted { $0.key < $1.key }, id: \.key) { date, ox in
                        LineMark(
                            x: .value("Day", date.day()),
                            y: .value("SpO2", ox)
                        )
                        .lineStyle(.init(lineWidth: 6, lineCap: .round))
                    }
                    
                    RuleMark(y: .value("Top", healthController.oxygenRangeTop))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    RuleMark(y: .value("Bottom", healthController.oxygenRangeBottom))
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
                    Text("Units: Percentage oxygen in blood (SpO2).")
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
    healthController.oxygenToday = 97.6
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.oxygenByDay[date] = Double(Int.random(in: 95...98))
        }
    }
    
    return OxygenReport()
        .environment(healthController)
}
