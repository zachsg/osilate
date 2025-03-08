//
//  MinutesSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct MinutesSection: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Query(sort: \OMeditate.date) var meditates: [OMeditate]
    @Query(sort: \O478Breath.date) var four78s: [O478Breath]
    @Query(sort: \OBoxBreath.date) var boxes: [OBoxBreath]
    
    var minToday: Int {
        var minutes = 0
        
        let todayMeditates = meditates.filter { $0.date.isToday() }
        let today478s = four78s.filter { $0.date.isToday() }
        let todayBoxes = boxes.filter { $0.date.isToday() }
        
        for meditate in todayMeditates { minutes += meditate.duration }
        
        for four78 in today478s { minutes += four78.duration }
        
        for box in todayBoxes { minutes += box.duration }
        
        return Int((Double(minutes) / 60).rounded())
    }
    
    var body: some View {
        HStack(spacing: 32) {
            VStack {
                HStack(spacing: 4) {
                    Text(minToday, format: .number)
                        .font(.title.bold())
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("min.")
                        
                        Text("spent")
                    }
                    .font(.caption2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
                .background(.accent)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 6, height: 6)))
                .padding(.horizontal, 2)
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                
                Text("Overall")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func isPastWeek(date: Date) -> Bool {
        let now: Date = .now
        let dayInSeconds = 86400.0
        let aWeekAgo = now.addingTimeInterval(dayInSeconds * -6)
        let range = aWeekAgo...now
        
        return range.contains(date)
    }
}

#Preview(traits: .sampleData) {
    MinutesSection()
}

