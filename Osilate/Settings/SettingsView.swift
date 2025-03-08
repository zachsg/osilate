//
//  SettingsView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal = dailyMoveGoalDefault
    @AppStorage(dailySweatGoalKey) var dailySweatGoal = dailySweatGoalDefault
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal = dailyBreatheGoalDefault
    
    var appVersion: String {
        UIApplication.appVersion ?? "Unknown"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper(value: $dailyMoveGoal.animation(), in: 500...30000, step: 250) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(dailyMoveGoal, format: .number)
                                .fontWeight(.bold)
                            Text("steps / day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: moveSystemImage)
                        Text(moveString)
                    }
                }
                
                Section {
                    Stepper(value: $dailySweatGoal.animation(), in: 300...3600, step: 300) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text((dailySweatGoal / 60), format: .number)
                                .fontWeight(.bold)
                            Text("minutes / day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: sweatSystemImage)
                        Text(sweatString)
                    }
                }
                
                Section {
                    Stepper(value: $dailyBreatheGoal.animation(), in: 300...7200, step: 300) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text((dailyBreatheGoal / 60), format: .number)
                                .fontWeight(.bold)
                            Text("minutes / day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: breatheSystemImage)
                        Text(breatheString)
                    }
                }
                
                Section {
                    // Left empty intentionally
                } footer: {
                    Text("Note: Weekly goals for move, sweat, breathe are auto-caculated based on your daily goals.")
                }
                
                Section {
                    // Add any dev info about the app
                } header: {
                    HStack {
                        Spacer()
                        Text("App: \(appVersion)")
                        Spacer()
                    }
                }
            }
            .navigationTitle(settingsString)
        }
    }
}

#Preview {
    SettingsView()
}
