//
//  StreaksSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct Streak: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let days: Int
}

struct StreaksSection: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \OMeditate.date, order: .reverse) var meditates: [OMeditate]
    @Query(sort: \O478Breath.date, order: .reverse) var four78s: [O478Breath]
    @Query(sort: \OBoxBreath.date, order: .reverse) var boxes: [OBoxBreath]
    
    var doesMeditate: Bool {
        !meditates.isEmpty
    }
    
    var meditateStreak: Int {
        calculateStreak(for: meditates)
    }
    
    var doesBreathe: Bool {
        !four78s.isEmpty || !boxes.isEmpty
    }
    
    var breatheStreak: Int {
        var breathes: [any OActivity] = []
        breathes.append(contentsOf: four78s)
        breathes.append(contentsOf: boxes)
        
        return calculateStreak(for: breathes)
    }
    
    var streaks: [Streak] {
        var s: [Streak] = []
        
        let all = [
            Streak(label: "Meditate", days: meditateStreak),
            Streak(label: "Breathe", days: breatheStreak)
        ].sorted { a, b in
            a.days > b.days
        }
        
        for item in all {
            if item.days > 0 {
                s.append(item)
            }
        }
        
        return s
    }
    
    var body: some View {
        if !streaks.isEmpty {
            if doesMeditate || doesBreathe {
                HStack {
                    ForEach(streaks, id: \.self) { streak in
                        StreakItem(label: streak.label, streak: streak.days)
                    }
                }
            } else {
                Text("No actions taken yet!")
                    .font(.headline)
            }
        } else {
            Text("No current streaks")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func calculateStreak(for activities: [any OActivity]) -> Int {
        var streak = 0
        
        var compareDay: Date = .now
        var daysAgo = 0
        let dayInSeconds = 86400
        let calendar = Calendar.current
        
        if !activities.isEmpty {
            if calendar.isDateInYesterday(activities.first!.date) {
                daysAgo = 1
            }
        }
        
        for activity in activities {
            compareDay = .now.addingTimeInterval(-TimeInterval(dayInSeconds * daysAgo))
            let activityDate = activity.date
            
            if calendar.isDate(activityDate, inSameDayAs: compareDay) {
                streak += 1
                daysAgo += 1
            } else if activityDate > compareDay {
            } else if activityDate < compareDay {
                if !calendar.isDateInToday(compareDay) {
                    break
                } else {
                    daysAgo += 1
                }
            }
        }
        
        return streak
    }
}

#Preview(traits: .sampleData) {
    StreaksSection()
}
