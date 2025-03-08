//
//  BreatheSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct BreatheSection: View {
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal = dailyBreatheGoalDefault
    
    var body: some View {
        Section {
            Stepper(value: $dailyBreatheGoal.animation(), in: 300...7200, step: 300) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Goal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text((dailyBreatheGoal / 60), format: .number)
                        .fontWeight(.bold)
                    Text("minutes / day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            HStack {
                Image(systemName: breatheSystemImage)
                Text(breatheString)
            }
        }
    }
}

#Preview {
    BreatheSection()
}
