//
//  ContentView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(HealthController.self) private var healthController
    
    @State private var tabSelected: OTabSelected = .summary
    
    var body: some View {
        TabView(selection: $tabSelected) {
            Tab(summaryString, systemImage: summarySystemImage, value: .summary) {
                SummaryView(tabSelected: $tabSelected)
            }
            
            Tab(moveString, systemImage: moveSystemImage, value: .move) {
                MoveView()
            }
            
            Tab(sweatString, systemImage: sweatSystemImage, value: .sweat) {
                SweatView()
            }
            
            Tab(breatheString, systemImage: breatheSystemImage, value: .breathe) {
                BreatheView()
            }
            
            Tab(settingsString, systemImage: settingsSystemImage, value: .settings) {
                SettingsView()
            }
        }
        .tint(tabTint(selection: tabSelected))
        .onAppear {
            healthController.getStepCountToday()
            healthController.getZone2Today()
            healthController.getMindfulMinutesToday()
            
            healthController.getStepCountWeek()
            healthController.getZone2Week()
            healthController.getMindfulMinutesWeek()
            
            healthController.getStepCountWeekByDay()
            healthController.getStepCountHourly()
            
            healthController.getZone2WeekByDay()
            healthController.getZone2Hourly()
            
            healthController.getStepCountFor(.day)
            healthController.getStepCountFor(.week)
            healthController.getStepCountFor(.month)
            
            healthController.getDistanceFor(.day)
            healthController.getDistanceFor(.week)
            healthController.getDistanceFor(.month)

            healthController.getStepCountDayByHour()
            healthController.getStepCountMonthByDay()
            
            healthController.getCardioFitnessRecent()
            healthController.getRhrRecent()
            healthController.getRecoveryRecent()

            healthController.getZone2Recent()
        }
    }
    
    private func tabTint(selection: OTabSelected) -> Color {
        return switch selection {
        case .summary:
            .accentColor
        case .move:
            .move
        case .sweat:
            .sweat
        case .breathe:
            .breathe
        default:
            .accentColor
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.stepCountToday = 3500
    healthController.stepCountWeek = 50000
    healthController.zone2Today = 5
    healthController.zone2Week = 60
    healthController.mindfulMinutesToday = 5
    healthController.mindfulMinutesWeek = 15
    
    let today: Date = .now
    for i in 0...6 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.stepCountWeekByDay[date] = Int.random(in: 0...20000)
            healthController.zone2WeekByDay[date] = Int.random(in: 0...50)
        }
    }
    
    return ContentView()
        .environment(healthController)
}
