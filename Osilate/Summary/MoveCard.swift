//
//  MoveCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct MoveCard: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal = dailyMoveGoalDefault
    
    var showToday: Bool
    var movePercent: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(showToday ? healthController.stepCountToday : healthController.stepCountWeek, format: .number)
                    .font(.title2.bold())
                    .foregroundStyle(.move)
                
                HStack(spacing: 4) {
                    Text("of")
                    Text(showToday ? dailyMoveGoal : dailyMoveGoal * 7, format: .number)
                    Text("steps")
                }
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(moveString.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.move)
            }
            
            ProgressView(value: movePercent)
                .scaleEffect(x: 1, y: 4)
                .tint(.move)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.stepCountToday = 5000
    healthController.stepCountWeek = 35000
    
    return MoveCard(showToday: true, movePercent: 0.7)
        .environment(healthController)
}
