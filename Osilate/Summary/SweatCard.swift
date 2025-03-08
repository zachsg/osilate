//
//  SweatCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct SweatCard: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(dailySweatGoalKey) var dailySweatGoal = dailySweatGoalDefault
    
    var showToday: Bool
    var sweatPercent: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(showToday ? healthController.zone2Today : healthController.zone2Week, format: .number)
                    .font(.title2.bold())
                    .foregroundStyle(.sweat)
                
                HStack(spacing: 4) {
                    Text("of")
                    Text((showToday ? dailySweatGoal : (dailySweatGoal * 7)) / 60, format: .number)
                    Text("minutes")
                }
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(sweatString.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.sweat)
            }
            
            ProgressView(value: sweatPercent)
                .scaleEffect(x: 1, y: 4)
                .tint(.sweat)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.zone2Today = 5
    healthController.zone2Week = 35
    
    return SweatCard(showToday: true, sweatPercent: 0.7)
        .environment(healthController)
}
