//
//  MoveSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct MoveSection: View {
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal = dailyMoveGoalDefault
    
    var body: some View {
        Section {
            Stepper(value: $dailyMoveGoal.animation(), in: 500...30000, step: 250) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("Goal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(dailyMoveGoal, format: .number)
                        .fontWeight(.bold)
                    Text("steps / day")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            HeaderLabel(title: moveString, systemImage: moveSystemImage, color: .move)
        }
    }
}

#Preview {
    MoveSection()
}
