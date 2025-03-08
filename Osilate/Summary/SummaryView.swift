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
    
    @AppStorage(dailyMoveGoalKey) var dailyMoveGoal = dailyMoveGoalDefault
    @AppStorage(dailySweatGoalKey) var dailySweatGoal = dailySweatGoalDefault
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal = dailyBreatheGoalDefault
    
    @State private var showToday = false
    @State private var animationAmount = 0.0
    
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
                VStack {
                    ZStack {
                        ZStack {
                            MoveRing(movePercent: movePercent)
                            
                            SweatRing(sweatPercent: sweatPercent)
                            
                            BreatheRing(breathePercent: breathePercent)
                            
                            SummaryDisplay(showToday: showToday, movePercent: movePercent, sweatPercent: sweatPercent, breathePercent: breathePercent)
                        }
                        .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
                    .onTapGesture {
                        withAnimation {
                            animationAmount = animationAmount == 0 ? 180 : 0
                            showToday.toggle()
                        }
                    }
                    
                    VStack(spacing: 12) {
                        MoveCard(showToday: showToday, movePercent: movePercent)
                        
                        SweatCard(showToday: showToday, sweatPercent: sweatPercent)
                        
                        BreatheCard(showToday: showToday, breathePercent: breathePercent)
                    }
                }
                .padding()
            }
            .refreshable {
                refresh()
            }
            .navigationTitle(summaryString)
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
        healthController.getStepCountToday()
        healthController.getZone2Today()
        healthController.getMindfulMinutesToday()
        
        healthController.getStepCountWeek()
        healthController.getZone2Week()
        healthController.getMindfulMinutesWeek()
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
    
    return SummaryView()
        .environment(healthController)
}
