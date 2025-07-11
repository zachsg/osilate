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
    @State private var mirroringSheetIsShowing = false
    
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
        .sheet(isPresented: $mirroringSheetIsShowing) {
            MirroringSheet(sheetIsShowing: $mirroringSheetIsShowing)
                .interactiveDismissDisabled()
        }
        .onChange(of: healthController.isMirroring) { oldValue, newValue in
            mirroringSheetIsShowing = newValue
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
    healthController.stepCountWeek = 30000
    healthController.zone2Today = 5
    healthController.zone2Week = 65
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
