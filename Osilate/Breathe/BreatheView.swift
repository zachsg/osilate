//
//  BreatheView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct BreatheView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OMeditate.date) private var meditates: [OMeditate]
    @Query(sort: \OBoxBreath.date) private var boxes: [OBoxBreath]
    @Query(sort: \O478Breath.date) private var four78s: [O478Breath]
    
    @State private var historySheetIsShowing = false
    @State private var meditateSheetIsShowing = false
    @State private var breathSheetIsShowing = false
    @State private var statsSheetIsShowing = false
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
    
    var body: some View {
        NavigationStack {
            VStack {
                if activities.isEmpty {
                    List {
                        StatsSection()
                        
                        Label("No time like the present. Let's take action!", systemImage: arrowSystemImage)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    List {
                        StatsSection()
                               
                        Section {
                            ForEach(activities, id: \.id) { activity in
                                ActivityCard(activity: activity)
                            }
                            .onDelete(perform: deleteActivities)
                        } header: {
                            Label("Actions", systemImage: actionsSystemImage)
                                .font(.footnote.bold())
                                .foregroundStyle(.accent)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        statsSheetIsShowing.toggle()
                    } label: {
                        Image(systemName: statsSystemImage)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        historySheetIsShowing.toggle()
                    } label: {
                        Image(systemName: historySystemImage)
                    }
                }
                
                ToolbarItem {
                    Button(breatheString, systemImage: breathSystemImage) {
                        breathSheetIsShowing.toggle()
                    }
                }
                
                ToolbarItem {
                    Button(meditateTitle, systemImage: meditateSystemImage) {
                        meditateSheetIsShowing.toggle()
                    }
                }
            }
            .navigationTitle(breatheString)
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
                }
            }
        }
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
