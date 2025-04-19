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
    @State private var showingInfoSheet = false
    
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
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Minutes")
                            .font(.caption)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(zone2, format: .number)
                                .font(.title2.bold())
                                .foregroundStyle(.sweat)
                            
                            HStack(spacing: 2) {
                                Text("of")
                                Text(showToday ? dailySweatGoal / 60 : (dailySweatGoal / 60) * 7, format: .number)
                            }
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        }
                    }
                }
                .padding(.vertical)
                .listRowInsets(EdgeInsets())
                
                Section {
                    StatRow(headerImage: vO2SystemImage, headerTitle: "Cardio fitness", date: healthController.latestCardioFitness, loading: healthController.cardioFitnessLoading, stat: healthController.cardioFitnessMostRecent, color: .sweat, units: vO2Units) {
                        VO2Chart()
                            .task {
                                healthController.getCardioFitnessRecent()
                                healthController.getZone2Recent()
                            }
                    } badge: {
                        VO2Badge()
                    }
                    
                    StatRow(headerImage: heartSystemImage, headerTitle: "Resting heart rate", date: healthController.latestRhr, loading: healthController.rhrLoading, stat: Double(healthController.rhrMostRecent), color: .sweat, units: heartUnits) {
                        RHRChart()
                            .task {
                                healthController.getRhrRecent()
                            }
                    } badge: {
                        RHRBadge()
                    }
                    
                    StatRow(headerImage: cardioRecoverySystemImage, headerTitle: "Cardio recovery", date: healthController.latestRecovery, loading: healthController.recoveryLoading, stat: Double(healthController.recoveryMostRecent), color: .sweat, units: heartUnits) {
                        RecoveryChart()
                            .task {
                                healthController.getRecoveryRecent()
                            }
                    } badge: {
                        RecoveryBadge()
                    }
                } header: {
                    HeaderLabel(title: "Progress", systemImage: streaksSystemImage, color: .accent)
                }
                
                Workouts()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
            .navigationTitle(sweatString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(infoTitle, systemImage: infoSystemImage) {
                        showingInfoSheet.toggle()
                    }
                    .tint(.sweat)
                }
            }
            .sheet(isPresented: $showingInfoSheet, content: {
                SweatInfoSheet(sheetIsShowing: $showingInfoSheet)
            })
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    refresh()
                }
            }
            .refreshable {
                refresh()
            }
        }
        .onAppear {
            refresh()
        }
    }
    
    private func refresh() {
        Task {
            healthController.getCardioFitnessRecent()
        }
        Task {
            healthController.getRhrRecent()
        }
        Task {
            healthController.getRecoveryRecent()
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    healthController.zone2Today = 10

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
