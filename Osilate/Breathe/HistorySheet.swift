//
//  HistorySheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct HistorySheet: View {
    @Binding var showingSheet: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \OMeditate.date) private var meditates: [OMeditate]
    @Query(sort: \OBoxBreath.date) private var boxes: [OBoxBreath]
    @Query(sort: \O478Breath.date) private var four78s: [O478Breath]
    
    var activities: [any OActivity] {
        var activities: [any OActivity] = []
        
        let pastMeditates = meditates.filter({ !$0.date.isToday() })
        let pastBoxes = boxes.filter({ !$0.date.isToday() })
        let past478s = four78s.filter({ !$0.date.isToday() })
        
        activities.append(contentsOf: pastMeditates)
        activities.append(contentsOf: pastBoxes)
        activities.append(contentsOf: past478s)
        
        return activities.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if activities.isEmpty {
                    Text("To have a past you must act in the present.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(32)
                } else {
                    List {
                        ForEach(activities, id: \.id) { activity in
                            ActivityCard(activity: activity)
                        }
                    }
                }
            }
            .navigationTitle(historyTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        showingSheet.toggle()
                    } label: {
                        Label(closeLabel, systemImage: cancelSystemImage)
                    }
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    HistorySheet(showingSheet: .constant(true))
}
