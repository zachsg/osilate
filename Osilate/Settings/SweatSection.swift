//
//  SweatSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct SweatSection: View {
    @AppStorage(dailySweatGoalKey) var dailySweatGoal = dailySweatGoalDefault
    @AppStorage(maxHrKey) var maxHr = maxHrDefault
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
                Stepper(value: $maxHr.animation(), in: 120...230, step: 1) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("Maximum HR")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text((maxHr), format: .number)
                            .fontWeight(.bold)
                        Text("bpm")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button("Auto-calculate max HR") {
                    maxHr = 220 - userAge
                }
                .buttonStyle(.bordered)
                .tint(.sweat)
            }
        } header: {
            HeaderLabel(title: sweatString, systemImage: sweatSystemImage, color: .sweat)
        } footer: {
            Text("Auto-calculation of max heart rate is based on your age.")
        }
        .onChange(of: maxHr) { oldValue, newValue in
            AppStorageSyncManager.shared.sendMaxHrToWatch(newValue)
        }
    }
}

#Preview {
    SweatSection()
}
