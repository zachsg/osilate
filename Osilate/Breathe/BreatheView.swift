//
//  BreatheView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct BreatheView: View {
    @Environment(HealthController.self) private var healthController
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OMeditate.date) private var meditates: [OMeditate]
    @Query(sort: \OBoxBreath.date) private var boxes: [OBoxBreath]
    @Query(sort: \O478Breath.date) private var four78s: [O478Breath]
    
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    @AppStorage(dailyBreatheGoalKey) var dailyBreatheGoal = dailyBreatheGoalDefault
    
    @State private var historySheetIsShowing = false
    @State private var meditateSheetIsShowing = false
    @State private var breathSheetIsShowing = false
    @State private var statsSheetIsShowing = false
    @State private var showingInfoAlert = false
    @State private var lastDate: Date = .now
    
    var activities: [any OActivity] {
        var activities: [any OActivity] = []
        
        let todayMeditates = meditates.filter({ $0.date.isToday() })
        let todayBoxes = boxes.filter({ $0.date.isToday() })
        let today478s = four78s.filter({ $0.date.isToday() })
        
        activities.append(contentsOf: todayMeditates)
        activities.append(contentsOf: todayBoxes)
        activities.append(contentsOf: today478s)
        
        return activities.sorted { $0.date > $1.date }
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
            VStack {
                if activities.isEmpty {
                    List {
                        ActivityRingAndStats(percent: breathePercent, color: .breathe) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Minutes")
                                    .font(.caption)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text(showToday ? healthController.mindfulMinutesToday : healthController.mindfulMinutesWeek, format: .number)
                                        .font(.title2.bold())
                                    
                                    HStack(spacing: 2) {
                                        Text("of")
                                        Text((showToday ? dailyBreatheGoal : (dailyBreatheGoal * 7)) / 60, format: .number)
                                    }
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical)
                        .listRowInsets(EdgeInsets())
                        
                        StatsSection()
                        
                        Label("No time like the present. Let's take action!", systemImage: arrowSystemImage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .refreshable {
                        refresh()
                    }
                } else {
                    List {
                        ActivityRingAndStats(percent: breathePercent, color: .breathe) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Minutes")
                                    .font(.caption)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text(showToday ? healthController.mindfulMinutesToday : healthController.mindfulMinutesWeek, format: .number)
                                        .font(.title2.bold())
                                        .foregroundStyle(.breathe)
                                    
                                    HStack(spacing: 2) {
                                        Text("of")
                                        Text((showToday ? dailyBreatheGoal : (dailyBreatheGoal * 7)) / 60, format: .number)
                                    }
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical)
                        .listRowInsets(EdgeInsets())
                        
                        StatsSection()
                        
                        Section {
                            ForEach(activities, id: \.id) { activity in
                                ActivityCard(activity: activity)
                            }
                            .onDelete(perform: deleteActivities)
                        } header: {
                            HeaderLabel(title: "Actions", systemImage: actionsSystemImage, color: .accent)
                        }
                    }
                    .refreshable {
                        refresh()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Info", systemImage: "info.circle") {
                        showingInfoAlert.toggle()
                    }
                    .tint(.breathe)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        statsSheetIsShowing.toggle()
                    } label: {
                        Image(systemName: statsSystemImage)
                    }
                    .tint(.breathe)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        historySheetIsShowing.toggle()
                    } label: {
                        Image(systemName: historySystemImage)
                    }
                    .tint(.breathe)
                }
                
                ToolbarItem {
                    Button(breatheString, systemImage: breathSystemImage) {
                        breathSheetIsShowing.toggle()
                    }
                    .tint(.breathe)
                }
                
                ToolbarItem {
                    Button(meditateTitle, systemImage: meditateSystemImage) {
                        meditateSheetIsShowing.toggle()
                    }
                    .tint(.breathe)
                }
            }
            .navigationTitle(breatheString)
            .navigationBarTitleDisplayMode(.inline)
            .alert("What's Breathe?", isPresented: $showingInfoAlert) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text("Breathe counts mindful minutes saved to Apple Health from any source.\n\nYou can change your goal in settings.")
            }
            .sheet(isPresented: $statsSheetIsShowing) {
                StatsSheet(showingSheet: $statsSheetIsShowing)
            }
            .sheet(isPresented: $historySheetIsShowing) {
                HistorySheet(showingSheet: $historySheetIsShowing)
            }
            .sheet(isPresented: $breathSheetIsShowing, content: {
                BreathSheet(showingSheet: $breathSheetIsShowing)
                    .interactiveDismissDisabled()
            })
            .sheet(isPresented: $meditateSheetIsShowing) {
                MeditateSheet(showingSheet: $meditateSheetIsShowing)
                    .interactiveDismissDisabled()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    if !Calendar.current.isDateInToday(lastDate) {
                        lastDate = .now
                        let meditate = OMeditate(date: Date.distantPast, duration: 0)
                        modelContext.insert(meditate)
                        modelContext.delete(meditate)
                    }
                    
                    refresh()
                }
            }
        }
    }
    
    private func refresh() {
        healthController.getMindfulMinutesFor(.day)
        healthController.getMindfulMinutesFor(.week)
    }

    private func deleteActivities(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let activity = activities[index]
                switch activity {
                case is OMeditate:
                    modelContext.delete(activity as! OMeditate)
                case is OBoxBreath:
                    modelContext.delete(activity as! OBoxBreath)
                case is O478Breath:
                    modelContext.delete(activity as! O478Breath)
                default:
                    modelContext.delete(activity)
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    BreatheView()
        .environment(HealthController())
}
