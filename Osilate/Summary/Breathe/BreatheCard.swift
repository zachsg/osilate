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
    
    @Binding var tabSelected: OTabSelected
    
    var showToday: Bool
    var breathePercent: Double
    
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup {
            Text("Graph goes here...")
        } label: {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(showToday ? healthController.mindfulMinutesToday : healthController.mindfulMinutesWeek, format: .number)
                        .font(.title2.bold())
                        .foregroundStyle(.breathe)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("of")
                            .font(.footnote)
                        Text((showToday ? dailyBreatheGoal : (dailyBreatheGoal * 7)) / 60, format: .number)
                        Text("minutes")
                            .font(.footnote)
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        tabSelected = .breathe
                    } label: {
                        Text(breatheString.uppercased())
                            .font(.caption.bold())
                            .foregroundStyle(.breathe)
                    }
                    .buttonStyle(.bordered)
                    .tint(.breathe)
                }
                
                ProgressView(value: breathePercent > 1 ? 1 : breathePercent)
                    .scaleEffect(x: 1, y: 4)
                    .tint(.breathe)
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal, 8)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.mindfulMinutesToday = 5
    healthController.mindfulMinutesWeek = 35
    
    return BreatheCard(tabSelected: .constant(.summary), showToday: true, breathePercent: 0.7)
        .environment(healthController)
}
