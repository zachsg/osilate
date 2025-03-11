//
//  Extensions.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftUI

#if os(iOS)
extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
#endif

extension TimeInterval {
    func secondsAsTime(units: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = units
        
        return formatter.string(from: TimeInterval(self)) ?? "n/a"
    }
    
    func secondsAsTimeRoundedToMinutes(units: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = units
        
        let secondsRounded = TimeInterval((self / 60.0).rounded() * 60)
        
        return formatter.string(from: TimeInterval(secondsRounded)) ?? "n/a"
    }
    
    func secondsToMinutesRounded() -> Int {
        Int((self / 60.0).rounded()) * 60
    }
    
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
}

extension OTimeOfDay {
    func systemImage() -> String {
        return switch self {
        case .morning:
            "sunrise.circle"
        case .midday:
            "sun.max.circle"
        case .evening:
            "sunset.circle"
        case .night:
            "moon.circle"
        }
    }
}

extension OActivity {
    func typeName() -> String {
        switch self {
        case is OMeditate:
            return "meditate"
        case is OBoxBreath:
            return "box breath"
        case is O478Breath:
            return "4-7-8 breath"
        default:
            return "Unknown"
        }
    }
}

extension Date {
    func day() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let date = dateFormatter.string(from: self)
        
        return date
    }
    
    func hour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        let hour = dateFormatter.string(from: self)
        
        return hour
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func timeOfDay() -> OTimeOfDay {
        let hour = Calendar.current.component(.hour, from: self)
        
        return switch hour {
        case 3..<10:
            .morning
        case 10..<15:
            .midday
        case 15..<19:
            .evening
        case 0..<3, 19...24:
            .night
        default:
            .midday
        }
    }
    
    func dateFormat() -> Date.FormatStyle {
        let calendar = Calendar.current
        
        return if calendar.isDateInToday(self) {
            .dateTime.hour().minute()
        } else if calendar.component(.year, from: self) == calendar.component(.year, from: .now) {
            .dateTime.day().month()
        } else {
            .dateTime.day().month().year()
        }
    }
    
    func weekDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let weekday = dateFormatter.string(from: self)
        
        return weekday
    }
    
    func getTodayAtHour(_ hour: Int) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)

        var newComponents = DateComponents()
        newComponents.year = components.year
        newComponents.month = components.month
        newComponents.day = components.day
        newComponents.hour = hour

        return calendar.date(from: newComponents)!
    }
    
    func topOfTheHour() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Int {
    func monthName(abbreviated: Bool = true) -> String {
        switch self {
        case 1:
            abbreviated ? "Jan" : "January"
        case 2:
            abbreviated ? "Feb" : "February"
        case 3:
            abbreviated ? "Mar" : "March"
        case 4:
            abbreviated ? "Apr" : "April"
        case 5:
            abbreviated ? "May" : "May"
        case 6:
            abbreviated ? "Jun" : "June"
        case 7:
            abbreviated ? "Jul" : "July"
        case 8:
            abbreviated ? "Aug" : "August"
        case 9:
            abbreviated ? "Sep" : "September"
        case 10:
            abbreviated ? "Oct" : "October"
        case 11:
            abbreviated ? "Nov" : "November"
        case 12:
            abbreviated ? "Dec" : "December"
        default:
            "N/A"
        }
    }
    
    func countSystemImage() -> String {
        return switch self {
        case 0...50:
            "\(self).circle"
        default:
            "circle"
        }
    }
    
    func rhrTrend(given average: Int) -> ORHRTrend {
        return if self >= average + 2 {
            .worsening
        } else if self <= average - 2 {
            .improving
        } else {
            .stable
        }
    }

    func recoveryTrend(given average: Int) -> ORecoveryTrend {
        return if self >= average + 2 {
            .improving
        } else if self <= average - 2 {
            .worsening
        } else {
            .stable
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func vO2Status() -> OVO2Status {
        @AppStorage(userAgeKey) var userAge: Int = userAgeDefault
        @AppStorage(userGenderKey) var userGender: OGender = userGenderDefault

        if self > 0 {
            let vO2TableForGender = vO2Lookup[userGender]

            if let vO2TableForGender {
                let status = vO2TableForGender.first(where:  { $0.ageRange.contains(userAge) })
                
                if let status {
                    let category = status.categories.first(where: { $0.vO2Range.contains(self.rounded()) })
                    
                    if let category {
                        return category.status
                    }
                }
            }
        }

        return .unknown
    }

    func vO2Trend(given average: Double) -> OVO2Trend {
        return if self >= average + 0.5 {
            .improving
        } else if self <= average - 0.5 {
            .worsening
        } else {
            .stable
        }
    }
}

struct ThousandsAbbreviationFormatStyle: FormatStyle {
    func format(_ value: Int) -> String {
        if value >= 1000 {
            let thousands = Double(value) / 1000.0
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0fk", thousands)
            } else {
                return String(format: "%.1fk", thousands)
            }
        } else {
            return String(value)
        }
    }
}

extension FormatStyle where Self == ThousandsAbbreviationFormatStyle {
    static var thousandsAbbr: ThousandsAbbreviationFormatStyle {
        ThousandsAbbreviationFormatStyle()
    }
}
