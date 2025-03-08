//
//  TimeSpentChart.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Charts
import SwiftData
import SwiftUI

struct Rest: Identifiable {
    var id = UUID()
    var date: Date
    var minutes: Int
    var type: String
}

struct TimeSpentChart: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \OMeditate.date) var meditates: [OMeditate]
    @Query(sort: \O478Breath.date) var four78s: [O478Breath]
    @Query(sort: \OBoxBreath.date) var boxes: [OBoxBreath]
    
    @Binding var timeFrame: OTimeFrame
    
    var meditateMinutes: Int {
        var minutes = 0
        
        let pastMeditates = meditates.filter { isInPast(period: timeFrame, date: $0.date) }
        for meditate in pastMeditates {
            minutes += meditate.duration
        }
        
        return minutes / 60
    }
    
    var breatheMinutes: Int {
        var minutes = 0
        
        let past478s = four78s.filter { isInPast(period: timeFrame, date: $0.date) }
        let pastBoxes = boxes.filter { isInPast(period: timeFrame, date: $0.date) }
        
        for past478 in past478s {
            minutes += past478.duration
        }
        
        for pastBox in pastBoxes {
            minutes += pastBox.duration
        }
        
        return minutes / 60
    }
    
    var averageMinutesPerDay: Int {
        var minutes = 0

        minutes += meditateMinutes
        minutes += breatheMinutes
        
        let minutesPerDay = Double(minutes) / timeFrame.days()
        
        return Int(minutesPerDay.rounded())
    }
    
    var weekData: [Rest] {
        var data: [Rest] = []
        
        let pastMeditates = meditates.filter { isInPast(period: timeFrame, date: $0.date) }
        let past478s = four78s.filter { isInPast(period: timeFrame, date: $0.date) }
        let pastBoxes = boxes.filter { isInPast(period: timeFrame, date: $0.date) }
        
        var day = 0.0
        let calendar = Calendar.current
        
        for i in (0...Int(timeFrame.days() - 1)).reversed() {
            day = Double(i) * 86400
            
            let checkDate: Date = .now.addingTimeInterval(-day)
            var minutes = 0
            for pastMeditate in pastMeditates {
                if calendar.isDate(checkDate, equalTo: pastMeditate.date, toGranularity: .day) {
                    minutes += pastMeditate.duration
                }
            }
            
            let rest = Rest(date: checkDate, minutes: minutes / 60, type: "Meditate")
            data.append(rest)
            
            minutes = 0
            for past478 in past478s {
                if calendar.isDate(checkDate, equalTo: past478.date, toGranularity: .day) {
                    minutes += past478.duration
                }
            }
            
            for pastBox in pastBoxes {
                if calendar.isDate(checkDate, equalTo: pastBox.date, toGranularity: .day) {
                    minutes += pastBox.duration
                }
            }
            
            let rest2 = Rest(date: checkDate, minutes: minutes / 60, type: "Breathe")
            data.append(rest2)
        }
        
        return data.sorted { a, b in
            a.type < b.type
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    StatItem(minutes: meditateMinutes, title: "Meditate")
                    Spacer()
                    StatItem(minutes: breatheMinutes, title: "Breathe")
                    Spacer()
                    StatItem(minutes: averageMinutesPerDay, title: "Daily Avg.")
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            GroupBox {
                Chart {
                    ForEach(weekData) { rest in
                        BarMark(
                            x: .value(timeFrame.rawValue, day(for: rest.date)),
                            y: .value("Minutes", rest.minutes)
                        )
                        .foregroundStyle(by: .value("Type", rest.type))
                        .cornerRadius(2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func day(for date: Date) -> String {
        return if timeFrame == .sevenDays {
            date.weekDay()
        } else if timeFrame == .twoWeeks {
            String(date.get(.day))
        } else if timeFrame == .sixMonths {
            date.get(.month).monthName()
        } else {
            String(date.get(.weekOfYear))
        }
    }
    
    private func isInPast(period: OTimeFrame, date: Date) -> Bool {
        let now: Date = .now
        let dayInSeconds = 86400.0
        let span = timeFrame.days()
        let aWeekAgo = now.addingTimeInterval(dayInSeconds * -span)
        let range = aWeekAgo...now
        
        return range.contains(date)
    }
}

#Preview(traits: .sampleData) {
    TimeSpentChart(timeFrame: .constant(.sevenDays))
}
