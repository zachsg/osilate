//
//  MoveCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct MoveCard: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal = dailyMoveGoalDefault
    
    @Binding var tabSelected: OTabSelected
    
    var movePercent: Double
    
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup {
            if showToday {
                DayStepsBarChart()
                    .padding(.top)
                    .task {
                        healthController.getStepCountDayByHour()
                    }
            } else {
                WeekStepsBarChart()
                    .padding(.top)
                    .task {
                        healthController.getStepCountWeekByDay()
                    }
            }
        } label: {
            Gauge(value: movePercent > 1 ? 1 : movePercent) {
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(showToday ? healthController.stepCountToday : healthController.stepCountWeek, format: .number)
                            .font(.title2.bold())
                            .foregroundStyle(.move)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("of")
                                .font(.footnote)
                            Text(showToday ? dailyMoveGoal : dailyMoveGoal * 7, format: .thousandsAbbr)
                            Text("steps")
                                .font(.footnote)
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                        .tint(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        tabSelected = .move
                    } label: {
                        Image(systemName: moveSystemImage)
                            .resizable()
                            .frame(width: 22, height: 22)
                    }
                }
            }
        }
        .tint(.move)
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal, 8)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.stepCountToday = 5000
    healthController.stepCountWeek = 35000
    
    return MoveCard(tabSelected: .constant(.summary), movePercent: 0.7)
        .environment(healthController)
}
