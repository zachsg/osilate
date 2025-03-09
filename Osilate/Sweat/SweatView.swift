//
//  SweatView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct SweatView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    @AppStorage(dailySweatGoalKey) var dailySweatGoal: Int = dailySweatGoalDefault

    @State private var zone2TodayPercent = 0.0
    @State private var zone2WeekPercent = 0.0
    
    var sweatPercent: Double {
        if showToday {
            (Double(healthController.zone2Today * 60) / Double(dailySweatGoal)).rounded(toPlaces: 2)
        } else {
            (Double(healthController.zone2Week * 60) / Double(dailySweatGoal * 7)).rounded(toPlaces: 2)
        }
    }
    
    var zone2: Int {
        if showToday {
            healthController.zone2Today
        } else {
            healthController.zone2Week
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ActivityRingAndStats(percent: sweatPercent, color: .sweat) {
                    HStack(spacing: 2) {
                        Text(zone2, format: .number)
                            .font(.title.bold())
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("minutes")
                            HStack(spacing: 4) {
                                Text("of")
                                Text(showToday ? dailySweatGoal / 60 : (dailySweatGoal / 60) * 7, format: .number)
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                    }
                }
                
                Section("Progress") {
                    StatRow(headerImage: vO2SystemImage, headerTitle: "Latest cardio fitness", date: healthController.latestCardioFitness, stat: healthController.cardioFitnessMostRecent, color: .sweat, units: vO2Units) {
                        VO2Chart()
                    } badge: {
                        VO2Badge()
                    }

                    StatRow(headerImage: vO2SystemImage, headerTitle: "Latest resting heart rate", date: healthController.latestRhr, stat: Double(healthController.rhrMostRecent), color: .sweat, units: heartUnits) {
                        RHRChart()
                    } badge: {
                        RHRBadge()
                    }

                    StatRow(headerImage: vO2SystemImage, headerTitle: "Latest cardio recovery", date: healthController.latestRecovery, stat: Double(healthController.recoveryMostRecent), color: .sweat, units: heartUnits) {
                        RecoveryChart()
                    } badge: {
                        RecoveryBadge()
                    }
                }
            }
            .navigationTitle(sweatString)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    refresh()
                }
            }
            .refreshable {
                refresh()
            }
        }
    }
    
    private func refresh() {
        healthController.getCardioFitnessRecent()
        healthController.getRhrRecent()
        healthController.getRecoveryRecent()

        healthController.getZone2Today()
        healthController.getZone2Week()
        healthController.getZone2Recent()
    }
}

#Preview {
    let healthController = HealthController()

    let today: Date = .now

    healthController.cardioFitnessMostRecent = 45
    healthController.cardioFitnessAverage = 43
    for i in 0...30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.cardioFitnessByDay[date] = Double.random(in: 40...45)
        }
    }

    for i in 0...30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.zone2ByDay[date] = Int.random(in: 0...45)
        }
    }

    healthController.rhrMostRecent = 60
    healthController.rhrAverage = 63
    for i in 0...30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.rhrByDay[date] = Int.random(in: 60...70)
        }
    }

    healthController.recoveryMostRecent = 32
    healthController.recoveryAverage = 30
    for i in 0...30 {
        let date = Calendar.current.date(byAdding: .day, value: -i, to: today)
        if let date {
            healthController.recoveryByDay[date] = Int.random(in: 28...33)
        }
    }

    return SweatView()
        .environment(healthController)
}
