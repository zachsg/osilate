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
    
    @Binding var tabSelected: OTabSelected
    
    var showToday: Bool
    var sweatPercent: Double
    
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup {
            if showToday {
                DayZone2BarChart()
                    .padding(.top)
                    .task {
                        healthController.getZone2Hourly()
                    }
            } else {
                WeekZone2BarChart()
                    .padding(.top)
                    .task {
                        healthController.getZone2WeekByDay()
                    }
            }
        } label: {
            Gauge(value: sweatPercent > 1 ? 1 : sweatPercent) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(showToday ? healthController.zone2Today : healthController.zone2Week, format: .number)
                        .font(.title2.bold())
                        .foregroundStyle(.sweat)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("of")
                            .font(.footnote)
                        Text((showToday ? dailySweatGoal : (dailySweatGoal * 7)) / 60, format: .number)
                        Text("minutes")
                            .font(.footnote)
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                    .tint(.secondary)
                    
                    Spacer()
                    
                    Button {
                        tabSelected = .sweat
                    } label: {
                        Text(sweatString.uppercased())
                            .font(.caption.bold())
                            .foregroundStyle(.sweat)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .tint(.sweat)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal, 8)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.zone2Today = 5
    healthController.zone2Week = 35
    
    return SweatCard(tabSelected: .constant(.summary), showToday: true, sweatPercent: 0.7)
        .environment(healthController)
}
