//
//  MoveView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct MoveView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal: Int = dailyMoveGoalDefault
    
    @State private var tab: OTimePeriod = .day
    @State private var animationAmount = 0.0
    @State private var showingInfoAlert = false
    
    var movePercent: Double {
        if showToday {
            (Double(healthController.stepCountToday) / Double(dailyMoveGoal)).rounded(toPlaces: 2)
        } else {
            (Double(healthController.stepCountWeek) / Double(dailyMoveGoal * 7)).rounded(toPlaces: 2)
        }
    }
    
    var steps: Int {
        if showToday {
            healthController.stepCountToday
        } else {
            healthController.stepCountWeek
        }
    }
    
    var distance: Double {
        if showToday {
            healthController.distanceToday
        } else {
            healthController.distanceWeek
        }
    }
    
    var distanceUnit: String {
        let unit = UnitLength(forLocale: .current)
        
        return if unit == UnitLength.feet {
            "miles"
        } else {
            "km"
        }
    }
    
    var completedDay: Double {
        let completed = Double(healthController.stepCountToday) / Double(dailyMoveGoal)
        return completed > 1 ? 1 : completed
    }
    
    var completedWeek: Double {
        let completed = Double(healthController.stepCountWeek) / Double(dailyMoveGoal * 7)
        return completed > 1 ? 1 : completed
    }
    
    var completedMonth: Double {
        let completed = Double(healthController.stepCountMonth) / Double(dailyMoveGoal * 30)
        return completed > 1 ? 1 : completed
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ActivityRingAndStats(percent: movePercent, color: .move) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Steps")
                            .font(.caption)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(steps, format: .thousandsAbbr)
                                .font(.title2.bold())
                                .foregroundStyle(.move)
                            
                            HStack(spacing: 2) {
                                Text("of")
                                Text(showToday ? dailyMoveGoal : dailyMoveGoal * 7, format: .thousandsAbbr)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(distanceUnit.capitalized)
                            .font(.caption)
                        
                        Text(distance.rounded(toPlaces: 1), format: .number)
                            .font(.title2.bold())
                            .foregroundStyle(.move)
                    }
                }
                .padding(.vertical, 10)
                .background {
                    if colorScheme == .dark {
                        Rectangle().fill(Material.regularMaterial)
                    } else {
                        Rectangle().fill(BackgroundStyle.background)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 36)
                .padding(.bottom, 22)
                .padding(.horizontal, 20)
                .background {
                    if colorScheme == .dark {
                        Rectangle().fill(BackgroundStyle.background)
                    } else {
                        Rectangle().fill(Material.regularMaterial)
                    }
                }
                
                Picker("Period", selection: $tab) {
                    ForEach(OTimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                TabView(selection: $tab) {
                    Tab("Day", systemImage: "", value: .day) {
                        StepsCardView(completed: completedDay, timeFrame: .day)
                    }
                    
                    Tab("Week", systemImage: "", value: .week) {
                        StepsCardView(completed: completedWeek, timeFrame: .week)
                    }
                    
                    Tab("Month", systemImage: "", value: .month) {
                        StepsCardView(completed: completedMonth, timeFrame: .month)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .refreshable {
                refresh()
            }
            .navigationTitle(moveString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Info", systemImage: "info.circle") {
                        showingInfoAlert.toggle()
                    }
                    .tint(.move)
                }
            }
            .alert("What's Move?", isPresented: $showingInfoAlert) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text("Move is based on the amount of steps you've taken.\n\nYou can change your goal in settings.")
            }
        }
        .onAppear {
            refresh()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                refresh()
            }
        }
        .onChange(of: showToday) { oldValue, newValue in
            if newValue {
                withAnimation {
                    tab = .day
                }
            } else {
                withAnimation {
                    tab = .week
                }
            }
        }
    }
    
    private func refresh() {
        healthController.getStepCountFor(.day)
        healthController.getStepCountFor(.week)
        healthController.getStepCountFor(.month)
        
        healthController.getDistanceFor(.day)
        healthController.getDistanceFor(.week)
        healthController.getDistanceFor(.month)

        healthController.getStepCountDayByHour()
        healthController.getStepCountWeekByDay()
        healthController.getStepCountMonthByDay()
    }
}

#Preview {
    let healthController = HealthController()
    healthController.stepCountToday = 5500
    healthController.stepCountWeek = 75000
    healthController.stepCountMonth = 250000
    healthController.distanceToday = 5
    healthController.distanceWeek = 25
    
    let calendar = Calendar.current
    let currentHour = calendar.dateComponents([.hour], from: .now)
    for i in 0...currentHour.hour! {
        let date = calendar.date(byAdding: .hour, value: -i, to: .now)
        if let date {
            healthController.stepCountDayByHour[date] = Int.random(in: 0...2000)
        }
    }
    
    return MoveView()
        .environment(healthController)
}
