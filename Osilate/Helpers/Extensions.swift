//
//  Extensions.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftUI
import UIKit

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

extension BodyMetricStatus {
    func color() -> Color {
        switch self {
        case .low:
            .orange
        case .normal:
            .green
        case .high:
            .red
        case .optimal:
            .blue
        case .missing:
            .secondary
        }
    }
    
    func systemName() -> String {
        switch self {
        case .low:
            lowRangeSystemImage
        case .normal:
            inRangeSystemImage
        case .high:
            highRangeSystemImage
        case .optimal:
            optimalRangeSystemImage
        case .missing:
            missingRangeSystemImage
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
    
    func isBetween(start: Date, end: Date) -> Bool {
        (start...end).contains(self)
    }
    
    func isPartOf(day: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: day)
        let start = startOfDay.addingTimeInterval(-hourInSeconds * 7)
        let end = startOfDay.addingTimeInterval(hourInSeconds * 10)
        
        return (start...end).contains(self)
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

func hrZone(_ zone: OZone, at startOrEnd: OZoneStartEnd) -> Int {
    @AppStorage(maxHrKey) var maxHr: Int = maxHrDefault
    
    if startOrEnd == .start {
        return switch zone {
        case .zero:
            0
        case .one:
            Int((Double(maxHr) * 0.5).rounded())
        case .two:
            Int((Double(maxHr) * 0.6).rounded())
        case .three:
            Int((Double(maxHr) * 0.7).rounded())
        case .four:
            Int((Double(maxHr) * 0.8).rounded())
        case .five:
            Int((Double(maxHr) * 0.9).rounded())
        }
    } else {
        return switch zone {
        case .zero:
            Int((Double(maxHr) * 0.5).rounded()) - 1
        case .one:
            Int((Double(maxHr) * 0.6).rounded()) - 1
        case .two:
            Int((Double(maxHr) * 0.7).rounded()) - 1
        case .three:
            Int((Double(maxHr) * 0.8).rounded()) - 1
        case .four:
            Int((Double(maxHr) * 0.9).rounded()) - 1
        case .five:
            maxHr
        }
    }
}

extension Double {
    func zoneRange(for zone: OZone) -> ClosedRange<Double> {
        switch zone {
        case .zero:
            return Double(hrZone(.zero, at: .start))...Double(hrZone(.zero, at: .end))
        case .one:
            return Double(hrZone(.one, at: .start))...Double(hrZone(.one, at: .end))
        case .two:
            return Double(hrZone(.two, at: .start))...Double(hrZone(.two, at: .end))
        case .three:
            return Double(hrZone(.three, at: .start))...Double(hrZone(.three, at: .end))
        case .four:
            return Double(hrZone(.four, at: .start))...Double(hrZone(.four, at: .end))
        case .five:
            return Double(hrZone(.five, at: .start))...300
        }
    }
    
    func zone() -> OZone {
        switch self {
        case zoneRange(for: .zero):
            return .zero
        case zoneRange(for: .one):
            return .one
        case zoneRange(for: .two):
            return .two
        case zoneRange(for: .three):
            return .three
        case zoneRange(for: .four):
            return .four
        case zoneRange(for: .five):
            return .five
        default:
            return .one
        }
    }
    
    func zoneColor() -> Color {
        switch self {
        case zoneRange(for: .zero):
            return .green
        case zoneRange(for: .one):
            return .blue
        case zoneRange(for: .two):
            return .yellow
        case zoneRange(for: .three):
            return .orange
        case zoneRange(for: .four):
            return .red
        case zoneRange(for: .five):
            return .purple
        default:
            return .clear
        }
    }
    
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

extension OZone {
    func color() -> Color {
        switch self {
        case .zero:
            return .green
        case .one:
            return .blue
        case .two:
            return .yellow
        case .three:
            return .orange
        case .four:
            return .red
        case .five:
            return .purple
        }
    }
}

extension FormatStyle where Self == ThousandsAbbreviationFormatStyle {
    static var thousandsAbbr: ThousandsAbbreviationFormatStyle {
        ThousandsAbbreviationFormatStyle()
    }
}

#if os(iOS)
extension View {
    func unlockRotation() -> some View {
        onAppear {
            UIApplication.shared.isIdleTimerDisabled = true

            AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false

            AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
            
            // Force portrait orientation
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { error in
                    print("Failed to update geometry: \(error)")
                }
            }
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
    }
}
#endif
