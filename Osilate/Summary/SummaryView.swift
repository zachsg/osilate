//
//  SummaryView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct SummaryView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal = dailyMoveGoalDefault
    @AppStorage(dailySweatGoalKey) var dailySweatGoal = dailySweatGoalDefault
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal = dailyBreatheGoalDefault
    
    @Binding var tabSelected: OTabSelected
    
    @State private var animationAmount = 0.0
    @State private var healthReportIsShowing = false
    
    var movePercent: Double {
        if showToday {
            (Double(healthController.stepCountToday) / Double(dailyMoveGoal)).rounded(toPlaces: 2)
        } else {
            (Double(healthController.stepCountWeek) / Double(dailyMoveGoal * 7)).rounded(toPlaces: 2)
        }
    }
    
    var sweatPercent: Double {
        if showToday {
            (Double(healthController.zone2Today * 60) / Double(dailySweatGoal)).rounded(toPlaces: 2)
        } else {
            (Double(healthController.zone2Week * 60) / Double(dailySweatGoal * 7)).rounded(toPlaces: 2)
        }
    }
    
    var breathePercent: Double {
        if showToday {
            (Double(healthController.mindfulMinutesToday * 60) / Double(dailyBreatheGoal)).rounded(toPlaces: 2)
        } else {
            (Double(healthController.mindfulMinutesWeek * 60) / Double(dailyBreatheGoal * 7)).rounded(toPlaces: 2)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    ZStack {
                        ActivityRing(percent: movePercent, color: .move, strokeWidth: 28, height: 280)
                        
                        ActivityRing(percent: sweatPercent, color: .sweat, strokeWidth: 28, height: 220)
                        
                        ActivityRing(percent: breathePercent, color: .breathe, strokeWidth: 28, height: 160)
                        
                        SummaryDisplay(movePercent: movePercent, sweatPercent: sweatPercent, breathePercent: breathePercent)
                    }
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
                .onTapGesture {
                    withAnimation {
                        animationAmount = animationAmount == 0 ? 180 : 0
                        showToday.toggle()
                    }
                }
                .padding(.vertical, 8)
                    
                VStack(spacing: 12) {
                    MoveCard(tabSelected: $tabSelected, movePercent: movePercent)
                    SweatCard(tabSelected: $tabSelected, sweatPercent: sweatPercent)
                    BreatheCard(tabSelected: $tabSelected, breathePercent: breathePercent)
                    
                    if healthController.isMirroring {
                        Text("Apple Watch workout started...")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .refreshable {
                refresh()
            }
            .navigationTitle(summaryString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button(healthReportTitle, systemImage: healthReportSystemImage) {
                        healthReportIsShowing.toggle()
                    }
                }
            }
            .sheet(isPresented: $healthReportIsShowing) {
                HealthReportSheet(sheetIsShowing: $healthReportIsShowing)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refresh()
            }
        }
        .onAppear {
            refresh()
        }
    }
    
    private func refresh() {
        Task {
            healthController.getStepCountFor(.day)
            healthController.getStepCountFor(.week)
        }
        Task {
            healthController.getZone2For(.day)
            healthController.getZone2For(.week)
        }
        Task {
            healthController.getMindfulMinutesFor(.day)
            healthController.getMindfulMinutesFor(.week)
        }
        
        if showToday {
            Task {
                healthController.getStepCountDayByHour()
                healthController.getZone2DayByHour()
            }
        } else {
            Task {
                healthController.getStepCountWeekByDay()
                healthController.getZone2WeekByDay()
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.stepCountToday = 3000
    healthController.stepCountWeek = 50000
    healthController.zone2Today = 5
    healthController.zone2Week = 60
    healthController.mindfulMinutesToday = 10
    healthController.mindfulMinutesWeek = 45
    
    return SummaryView(tabSelected: .constant(.summary))
        .environment(healthController)
}
