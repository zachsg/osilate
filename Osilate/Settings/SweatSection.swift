//
//  SweatSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct SweatSection: View {
    @AppStorage(dailySweatGoalKey) var dailySweatGoal = dailySweatGoalDefault
    @AppStorage(zone2MinKey) var zone2Min = zone2MinDefault
    @AppStorage(userAgeKey) var userAge = userAgeDefault
    
    var body: some View {
        Section {
            Stepper(value: $dailySweatGoal.animation(), in: 300...3600, step: 300) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Goal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text((dailySweatGoal / 60), format: .number)
                        .fontWeight(.bold)
                    Text("minutes / day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack {
                Stepper(value: $zone2Min.animation(), in: 100...200, step: 1) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("Zone 2 starts at")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text((zone2Min), format: .number)
                            .fontWeight(.bold)
                        Text("bpm")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button("Auto-calculate Zone 2") {
                    zone2Min = Int((Double(220 - userAge) * 0.7).rounded())
                }
                .buttonStyle(.bordered)
            }
        } header: {
            HeaderLabel(title: sweatString, systemImage: sweatSystemImage, color: .sweat)
        } footer: {
            Text("Auto-calculation of Zone 2 is based on your age.")
        }
    }
}

#Preview {
    SweatSection()
}
