//
//  SummaryDisplay.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct SummaryDisplay: View {
    var showToday: Bool
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
                .font(.subheadline.bold())
                
                Divider()
                    .frame(height: 60)
                
                VStack(alignment: .leading) {
                    Text(movePercent, format: .percent)
                        .foregroundStyle(.move)
                    Text(sweatPercent, format: .percent)
                        .foregroundStyle(.sweat)
                    Text(breathePercent, format: .percent)
                        .foregroundStyle(.breathe)
                }
                .font(.subheadline)
                .fontWeight(.heavy)
            }
        }
    }
}

#Preview {
    SummaryDisplay(showToday: true, movePercent: 0.7, sweatPercent: 0.5, breathePercent: 0.3)
}
