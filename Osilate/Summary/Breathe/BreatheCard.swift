//
//  BreatheCard.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct BreatheCard: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal = dailyBreatheGoalDefault
    
    @Binding var tabSelected: OTabSelected
    
    var breathePercent: Double
    
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup {
            if showToday {
                DayBreatheBarChart()
                    .padding(.top)
                    .task {
                        healthController.getMindfulMinutesDayByHour()
                    }
            } else {
                WeekBreatheBarChart()
                    .padding(.top)
                    .task {
                        healthController.getMindfulMinutesWeekByDay()
                    }
            }
        } label: {
            Gauge(value: breathePercent > 1 ? 1 : breathePercent) {
                HStack {
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
                        .tint(.secondary)
                    }
                    
                    Spacer()
                    
                    if healthController.mindfulMinutesLoading {
                        ProgressView()
                    } else {
                        Button {
                            tabSelected = .breathe
                        } label: {
                            Image(systemName: breatheSystemImage)
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                    }
                }
            }
        }
        .tint(.breathe)
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
        .padding(.horizontal, 8)
    }
}

#Preview {
    let healthController = HealthController()
    healthController.mindfulMinutesToday = 5
    healthController.mindfulMinutesWeek = 35
    
    return BreatheCard(tabSelected: .constant(.summary), breathePercent: 0.7)
        .environment(healthController)
}
