//
//  BreatheCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct BreatheCard: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal = dailyBreatheGoalDefault
    
    var showToday: Bool
    var breathePercent: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(showToday ? healthController.mindfulMinutesToday : healthController.mindfulMinutesWeek, format: .number)
                    .font(.title2.bold())
                    .foregroundStyle(.breathe)
                
                HStack(spacing: 4) {
                    Text("of")
                    Text((showToday ? dailyBreatheGoal : (dailyBreatheGoal * 7)) / 60, format: .number)
                    Text("minutes")
                }
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(breatheString.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.breathe)
            }
            
            ProgressView(value: breathePercent)
                .scaleEffect(x: 1, y: 4)
                .tint(.breathe)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.mindfulMinutesToday = 5
    healthController.mindfulMinutesWeek = 35
    
    return BreatheCard(showToday: true, breathePercent: 0.7)
        .environment(healthController)
}
