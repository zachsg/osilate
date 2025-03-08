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
                SummaryView()
            }
            
            Tab(moveString, systemImage: moveSystemImage, value: .move) {
                Text("Move")
            }
            
            Tab(sweatString, systemImage: sweatSystemImage, value: .sweat) {
                Text("Sweat")
            }
            
            Tab(breatheString, systemImage: breatheSystemImage, value: .breathe) {
                BreatheView()
            }
            
            Tab(settingsString, systemImage: settingsSystemImage, value: .settings) {
                SettingsView()
            }
        }
        .tint(tabTint(selection: tabSelected))
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
        healthController.stepCountToday = 3000
        healthController.stepCountWeek = 50000
        healthController.zone2Today = 5
        healthController.zone2Week = 60
        healthController.mindfulMinutesToday = 5
        healthController.mindfulMinutesWeek = 15
    
    return ContentView()
        .environment(healthController)
}
