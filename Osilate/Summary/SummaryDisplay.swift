//
//  SummaryDisplay.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct SummaryDisplay: View {
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    
    var movePercent: Double
    var sweatPercent: Double
    var breathePercent: Double

    var body: some View {
        VStack {
            Text(showToday ? "TODAY" : "PAST 7 DAYS")
                .font(.caption.bold())
                .fontWeight(.heavy)
                .foregroundStyle(.secondary)
            
            if !showToday {
                Text("includes today")
                    .font(.caption2.italic())
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                VStack(alignment: .trailing) {
                    Text("Move")
                        .foregroundStyle(.move)
                    Text("Sweat")
                        .foregroundStyle(.sweat)
                    Text("Breathe")
                        .foregroundStyle(.breathe)
                }
                .font(.footnote.bold())
                
                Divider()
                    .frame(width: 1, height: 60)
                    .background(.secondary)
                
                VStack(alignment: .leading) {
                    Text(movePercent, format: .percent)
                        .foregroundStyle(.move)
                    Text(sweatPercent, format: .percent)
                        .foregroundStyle(.sweat)
                    Text(breathePercent, format: .percent)
                        .foregroundStyle(.breathe)
                }
                .font(.footnote)
                .fontWeight(.heavy)
            }
        }
    }
}

#Preview {
    SummaryDisplay(showToday: true, movePercent: 0.7, sweatPercent: 0.5, breathePercent: 0.3)
}
