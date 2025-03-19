//
//  HealthController.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import HealthKit
import SwiftUI

@Observable
class HealthController {
    var healthStore = HKHealthStore()
    
    // Steps
    var stepCountToday = 0
    var stepCountWeek = 0
    var stepCountMonth = 0
    var stepCountDayByHour: [Date: Int] = [:]
    var stepCountWeekByDay: [Date: Int] = [:]
    var stepCountMonthByDay: [Date: Int] = [:]
    var latestSteps: Date = .now
    
    var stepsDayByHourLoading = false
    var stepsWeekByDayLoading = false
    var stepsMonthByDayLoading = false
    
    // Zone 2
    var zone2Today = 0
    var zone2Week = 0
    var zone2DayByHour: [Date: Int] = [:]
    var zone2WeekByDay: [Date: Int] = [:]
    var zone2ByDay: [Date: Int] = [:]
    var latestZone2: Date = .now
    
    var zone2DayByHourLoading = false
    var zone2WeekByDayLoading = false
    var zone2ByDayLoading = false

    // Walk/run distance
    var walkRunDistanceToday = 0.0
    var latestWalkRunDistance: Date = .now
    
    var distanceToday = 0.0
    var distanceWeek = 0.0
    var distanceMonth = 0.0
    
    // VO2 max
    var cardioFitnessMostRecent = 0.0
    var cardioFitnessAverage = 0.0
    var cardioFitnessByDay: [Date: Double] = [:]
    var latestCardioFitness: Date = .now
    var cardioFitnessLoading = false
    
    // Resting heart rate
    var rhrMostRecent = 0
    var rhrAverage = 0
    var rhrByDay: [Date: Int] = [:]
    var latestRhr: Date = .now
    var hasRhrToday = false
    var rhrLoading = false
    
    var rhrRangeTop: Int = 0
    var rhrRangeBottom: Int = 0
    var rhrMeasuredTop: Int = 0
    var rhrMeasuredBottom: Int = 0
    var rhrStatus: BodyMetricStatus = .normal

    // Cardio recovery
    var recoveryMostRecent = 0
    var recoveryAverage = 0
    var recoveryByDay: [Date: Int] = [:]
    var latestRecovery: Date = .now
    var recoveryLoading = false
    
    // Mindful Minutes
    var mindfulMinutesToday = 0
    var latestMindfulMinutes: Date = .now
    var mindfulMinutesWeek = 0
    var mindfulMinutesWeekByDay: [Date: Int] = [:]
    var mindfulMinutesDayByHour: [Date: Int] = [:]
    
    var mindfulMinutesDayByHourLoading = false
    var mindfulMinutesWeekByDayLoading = false
    
    // Body temp
    var bodyTempLoading = false
    var bodyTempToday = 0.0
    var bodyTempByDayLoading = false
    var bodyTempByDay: [Date: Double] = [:]
    var hasBodyTempToday = false
    var bodyTempLastUpdated: Date = .now
    
    var bodyTempRangeTop: Double = 0.0
    var bodyTempRangeBottom: Double = 0.0
    var bodyTempMeasuredTop: Double = 0.0
    var bodyTempMeasuredBottom: Double = 0.0
    var bodyTempStatus: BodyMetricStatus = .normal

    // Respiration
    var respirationLoading = false
    var respirationToday = 0.0
    var respirationByDayLoading = false
    var respirationByDay: [Date: Double] = [:]
    var hasRespirationToday = false
    var respirationLastUpdated: Date = .now
    
    var respirationRangeTop: Double = 0.0
    var respirationRangeBottom: Double = 0.0
    var respirationMeasuredTop: Double = 0.0
    var respirationMeasuredBottom: Double = 0.0
    var respirationStatus: BodyMetricStatus = .normal
    
    // Blood oxygen
    var oxygenLoading = false
    var oxygenToday = 0.0
    var oxygenByDayLoading = false
    var oxygenByDay: [Date: Double] = [:]
    var hasOxygenToday = false
    var oxygenLastUpdated: Date = .now
    
    var oxygenRangeTop: Double = 0.0
    var oxygenRangeBottom: Double = 0.0
    var oxygenMeasuredTop: Double = 0.0
    var oxygenMeasuredBottom: Double = 0.0
    var oxygenStatus: BodyMetricStatus = .normal
    
    // Heart rate variability
    var hrvLoading = false
    var hrvToday = 0.0
    var hrvByDayLoading = false
    var hrvByDay: [Date: Double] = [:]
    var hasHrvToday = false
    var hrvLastUpdated: Date = .now
    
    var hrvRangeTop: Double = 0.0
    var hrvRangeBottom: Double = 0.0
    var hrvMeasuredTop: Double = 0.0
    var hrvMeasuredBottom: Double = 0.0
    var hrvStatus: BodyMetricStatus = .normal
    
    // Sleep
    var sleepLoading = false
    var sleepToday = 0.0
    var sleepByDayLoading = false
    var sleepByDay: [Date: Double] = [:]
    var hasSleepToday = false
    var sleepLastUpdated: Date = .now
    
    var sleepRangeTop: Double = 0.0
    var sleepRangeBottom: Double = 0.0
    var sleepMeasuredTop: Double = 0.0
    var sleepMeasuredBottom: Double = 0.0
    var sleepStatus: BodyMetricStatus = .normal
    
    init() {
        requestAuthorization()
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        let toRead = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .vo2Max)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType(.appleSleepingWristTemperature),
            HKQuantityType(.respiratoryRate),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.heartRateVariabilitySDNN)
//            HKQuantityType(.physicalEffort),
//            HKQuantityType(.appleStandTime),
//            HKQuantityType(.flightsClimbed),
        ])
        let toShare = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ])
            
        guard HKHealthStore.isHealthDataAvailable() else {
            print("health data not available!")
            return
        }
        
        healthStore.requestAuthorization(toShare: toShare, read: toRead) { success, error in
            if !success {
                print("\(String(describing: error))")
            }
        }
    }
    
    // MARK: - Steps
    func getStepCountFor(_ timeFrame: OTimePeriod) {
        let quantityType = HKQuantityType(.stepCount)
        
        let calendar = Calendar.current
        
        let predicate: NSPredicate
        switch timeFrame {
        case .day:
            let startDate = Calendar.current.startOfDay(for: .now)
            predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: .now,
                options: .strictStartDate
            )
        case .week:
            let todayNumber = calendar.component(.weekday, from: .now)
            let sixDaysAgo = todayNumber == 7 ? 1 : todayNumber + 1
            let components = DateComponents(
                calendar: calendar,
                timeZone: calendar.timeZone,
                hour: 3,
                minute: 0,
                second: 0,
                weekday: sixDaysAgo
            )
            
            guard let anchorDate = calendar.nextDate(
                after: .now,
                matching: components,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .backward
            ) else {
                fatalError("*** unable to find the previous Monday. ***")
            }
            
            predicate = HKQuery.predicateForSamples(
                withStart: anchorDate,
                end: .now,
                options: .strictStartDate
            )
        case .month:
            let monthAgo = calendar.startOfDay(for: .now.addingTimeInterval(-86400 * 30))
            
            predicate = HKQuery.predicateForSamples(
                withStart: monthAgo,
                end: .now,
                options: .strictStartDate
            )
        }
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "UNKNOWN ERROR")")
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            
            DispatchQueue.main.async {
                switch timeFrame {
                case .day:
                    self.stepCountToday = steps
                case .week:
                    self.stepCountWeek = steps
                case .month:
                    self.stepCountMonth = steps
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func getStepCountMonthByDay(refresh: Bool = false) {
        let calendar = Calendar.current
        
        let interval = DateComponents(day: 1)
        let monthAgo = calendar.startOfDay(for: .now.addingTimeInterval(-86400 * 30))
        
        let quantityType = HKQuantityType(.stepCount)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: monthAgo,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                assertionFailure("")
                return
            }
            
            let endDate = Date.now
            let startDate = calendar.startOfDay(for: .now.addingTimeInterval(-86400 * 30))
            
            var stepCountMonthByDayTemp: [Date: Int] = [:]
            statsCollection.enumerateStatistics(from: startDate, to: endDate)
            { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: .count())
                    stepCountMonthByDayTemp[date] = Int(value)
                }
            }
            
            DispatchQueue.main.async {
                self.stepCountMonthByDay = stepCountMonthByDayTemp
                self.stepsMonthByDayLoading = false
            }
        }
        
        if refresh {
            stepCountMonthByDay = [:]
        }
        
        stepsMonthByDayLoading = true
        
        healthStore.execute(query)
    }
    
    func getStepCountWeekByDay(refresh: Bool = false) {
        let calendar = Calendar.current
        
        let interval = DateComponents(day: 1)
        let todayNumber = calendar.component(.weekday, from: .now)
        let sixDaysAgo = todayNumber == 7 ? 1 : todayNumber + 1
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            hour: 3,
            minute: 0,
            second: 0,
            weekday: sixDaysAgo
        )
        
        guard let anchorDate = calendar.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .backward
        ) else {
            fatalError("*** unable to find the previous Monday. ***")
        }
        
        let quantityType = HKQuantityType(.stepCount)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                assertionFailure("")
                return
            }
            
            let endDate = Date()
            let oneWeekAgo = DateComponents(day: -6)
            
            guard let startDate = calendar.date(byAdding: oneWeekAgo, to: endDate) else {
                fatalError("*** Unable to calculate the start date ***")
            }
            
            var stepCountWeekByDayTemp: [Date: Int] = [:]
            statsCollection.enumerateStatistics(from: startDate, to: endDate)
            { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: .count())
                    
                    stepCountWeekByDayTemp[date] = Int(value)
                }
            }
            
            DispatchQueue.main.async {
                self.stepCountWeekByDay = stepCountWeekByDayTemp
                self.stepsWeekByDayLoading = false
            }
        }
        
        if refresh {
            stepCountWeekByDay = [:]
        }
        
        stepsWeekByDayLoading = true
        
        healthStore.execute(query)
    }
    
    func getStepCountDayByHour(refresh: Bool = false) {
        let calendar = Calendar.current
        
        let interval = DateComponents(hour: 1)
        let startOfToday = calendar.startOfDay(for: .now)
        
        let quantityType = HKQuantityType(.stepCount)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: startOfToday,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                assertionFailure("")
                return
            }
            
            let endDate = Date.now
            let startDate = calendar.startOfDay(for: .now)
            
            var stepCountDayByHourTemp: [Date: Int] = [:]
            statsCollection.enumerateStatistics(from: startDate, to: endDate)
            { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: .count())
                    stepCountDayByHourTemp[date] = Int(value)
                }
            }
            
            for i in 1...24 {
                let hour = Date.now.getTodayAtHour(i)
                stepCountDayByHourTemp[hour] = stepCountDayByHourTemp[hour] ?? 0
            }
            
            DispatchQueue.main.async {
                self.stepCountDayByHour = stepCountDayByHourTemp
                self.stepsDayByHourLoading = false
            }
        }
        
        if refresh {
            stepCountDayByHour = [:]
        }
        
        stepsDayByHourLoading = true
        
        healthStore.execute(query)
    }
    
    // MARK: - Zone 2
    func getZone2For(_ timeFrame: OTimePeriod) {
        @AppStorage(zone2MinKey) var zone2Min: Int = zone2MinDefault
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }
        
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        
        let calendar = Calendar.current
        
        let predicate: NSPredicate
        switch timeFrame {
        case .day:
            let startDate = Calendar.current.startOfDay(for: .now)
            predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: .now,
                options: .strictStartDate
            )
        case .week:
            let todayNumber = calendar.component(.weekday, from: .now)
            let sixDaysAgo = todayNumber == 7 ? 1 : todayNumber + 1
            let components = DateComponents(
                calendar: calendar,
                timeZone: calendar.timeZone,
                hour: 3,
                minute: 0,
                second: 0,
                weekday: sixDaysAgo
            )
            
            guard let anchorDate = calendar.nextDate(
                after: .now,
                matching: components,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .backward
            ) else {
                fatalError("*** unable to find the previous Monday. ***")
            }
            
            predicate = HKQuery.predicateForSamples(
                withStart: anchorDate,
                end: .now,
                options: .strictStartDate
            )
        case .month:
            return
        }
        
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard error == nil else {
                print("error")
                return
            }
            
            var total = 0
            var latest: Date?
            for (_, sample) in results!.enumerated() {
                guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
                
                let heartRate = currData.quantity.doubleValue(for: heartRateUnit)
                
                if heartRate >= Double(zone2Min) {
                    let zone3 = zone2Min.hrZone(.three)
                    let zone4 = zone2Min.hrZone(.four)
                    let zone5 = zone2Min.hrZone(.five)
                    
                    let multiplier = if heartRate >= Double(zone5) {
                        4
                    } else if heartRate >= Double(zone4) {
                        3
                    } else if heartRate >= Double(zone3) {
                        2
                    } else {
                        1
                    }
                    
                    if let latest {
                        let timeSinceLastZone2 = (sample.startDate.timeIntervalSince(latest).second * multiplier)
                        if timeSinceLastZone2 < 120 {
                            total += timeSinceLastZone2
                        } else {
                            total += multiplier
                        }
                    } else {
                        total += multiplier
                    }
                    
                    latest = sample.startDate
                }
            }
            
            DispatchQueue.main.async {
                let minutes = Int((Double(total) / 60).rounded())
                
                switch timeFrame {
                case .day:
                    self.zone2Today = minutes
                case .week:
                    self.zone2Week = minutes
                case .month:
                    return
                }

                self.latestZone2 = latest ?? .now
            }
        })
        
        healthStore.execute(query)
    }
    
    func getZone2WeekByDay(refresh: Bool = false) {
        @AppStorage(zone2MinKey) var zone2Min: Int = zone2MinDefault
        
        let calendar = Calendar.current
        
        // Set the anchor for 3 a.m. 6 days ago.
        let todayNumber = calendar.component(.weekday, from: .now)
        let sixDaysAgo = todayNumber == 7 ? 1 : todayNumber + 1
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            hour: 3,
            minute: 0,
            second: 0,
            weekday: sixDaysAgo
        )
        
        guard let anchorDate = calendar.nextDate(
            after: .now,
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .backward
        ) else {
            fatalError("*** unable to find the previous Monday. ***")
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: anchorDate,
            end: .now,
            options: .strictStartDate
        )
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }
        
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard error == nil else {
                print("error")
                return
            }
            
            var latest: Date?
            var zone2WeekByDayTemp: [Date: Int] = [:]
            for (_, sample) in results!.enumerated() {
                guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
                
                let heartRate = currData.quantity.doubleValue(for: heartRateUnit)
                if heartRate >= Double(zone2Min) {
                    let zone3 = zone2Min.hrZone(.three)
                    let zone4 = zone2Min.hrZone(.four)
                    let zone5 = zone2Min.hrZone(.five)
                    
                    let multiplier = if heartRate >= Double(zone5) {
                        4
                    } else if heartRate >= Double(zone4) {
                        3
                    } else if heartRate >= Double(zone3) {
                        2
                    } else {
                        1
                    }
                    
                    let date = calendar.startOfDay(for: sample.startDate)
                    let value = zone2WeekByDayTemp[date] ?? multiplier
                    if let latest {
                        let timeSinceLastZone2 = (sample.startDate.timeIntervalSince(latest).second * multiplier)
                        if timeSinceLastZone2 < 120 {
                            zone2WeekByDayTemp[date] = value + timeSinceLastZone2
                        } else {
                            zone2WeekByDayTemp[date] = value
                        }
                    } else {
                        zone2WeekByDayTemp[date] = value
                    }
                    
                    latest = sample.startDate
                }
            }
            
            var checking: Date = calendar.startOfDay(for: .now)
            for _ in 1...7 {
                if zone2WeekByDayTemp[checking] != nil {
                    let value = zone2WeekByDayTemp[checking] ?? 0
                    zone2WeekByDayTemp[checking] = Int((Double(value) / 60).rounded())
                } else {
                    zone2WeekByDayTemp[checking] = 0
                }
                checking = checking.addingTimeInterval(-hourInSeconds * 24)
            }
            
            DispatchQueue.main.async {
                self.latestZone2 = latest ?? .distantPast
                self.zone2WeekByDay = zone2WeekByDayTemp
                self.zone2WeekByDayLoading = false
            }
        })
        
        if refresh {
            zone2WeekByDay = [:]
        }
        
        zone2WeekByDayLoading = true
        
        healthStore.execute(query)
    }
    
    func getZone2DayByHour(refresh: Bool = false) {
        @AppStorage(zone2MinKey) var zone2Min: Int = zone2MinDefault
        
        let calendar = Calendar.current
        
        let anchorDate = calendar.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(
            withStart: anchorDate,
            end: .now,
            options: .strictStartDate
        )
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }
        
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard error == nil else {
                print("error")
                return
            }
            
            var latest: Date?
            var zone2DayByHourTemp: [Date: Int] = [:]
            for (_, sample) in results!.enumerated() {
                guard let currData: HKQuantitySample = sample as? HKQuantitySample else { return }
                
                let heartRate = currData.quantity.doubleValue(for: heartRateUnit)
                if heartRate >= Double(zone2Min) {
                    let zone3 = zone2Min.hrZone(.three)
                    let zone4 = zone2Min.hrZone(.four)
                    let zone5 = zone2Min.hrZone(.five)
                    
                    let multiplier = if heartRate >= Double(zone5) {
                        4
                    } else if heartRate >= Double(zone4) {
                        3
                    } else if heartRate >= Double(zone3) {
                        2
                    } else {
                        1
                    }
                    
                    let date = sample.startDate.topOfTheHour()
                    let value = zone2DayByHourTemp[date] ?? multiplier
                    if let latest {
                        let timeSinceLastZone2 = (sample.startDate.timeIntervalSince(latest).second * multiplier)
                        if timeSinceLastZone2 < 120 {
                            zone2DayByHourTemp[date] = value + timeSinceLastZone2
                        } else {
                            zone2DayByHourTemp[date] = value
                        }
                    } else {
                        zone2DayByHourTemp[date] = value
                    }
                    
                    latest = sample.startDate
                }
            }
            
            for i in 1...24 {
                let hour = Date.now.getTodayAtHour(i)
                let value = Int((Double(zone2DayByHourTemp[hour] ?? 0) / 60).rounded())
                zone2DayByHourTemp[hour] = value
            }
            
            DispatchQueue.main.async {
                self.latestZone2 = latest ?? .distantPast
                self.zone2DayByHour = zone2DayByHourTemp
                self.zone2DayByHourLoading = false
            }
        })
        
        if refresh {
            zone2DayByHour = [:]
        }
        
        zone2DayByHourLoading = true
        
        healthStore.execute(query)
    }
    
    func getZone2Recent(refresh: Bool = false) {
        @AppStorage(zone2MinKey) var zone2Min: Int = zone2MinDefault
        
        let calendar = Calendar.current
        
        // Set the anchor for 3 a.m. 60 days ago.
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: Date())!
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: calendar.component(.year, from: sixtyDaysAgo),
            month: calendar.component(.month, from: sixtyDaysAgo),
            day: calendar.component(.day, from: sixtyDaysAgo),
            hour: 3,
            minute: 0,
            second: 0
        )
        
        guard let anchorDate = calendar.nextDate(
            after: .now,
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .backward
        ) else {
            fatalError("*** unable to find the previous Monday. ***")
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: anchorDate,
            end: .now,
            options: .strictStartDate
        )
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }
        
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard error == nil else {
                print("error")
                return
            }
            
            var latest: Date?
            var zone2RecentTemp: [Date: Int] = [:]
            for (_, sample) in results!.enumerated() {
                guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
                
                let heartRate = currData.quantity.doubleValue(for: heartRateUnit)
                if heartRate >= Double(zone2Min) {
                    let zone3 = zone2Min.hrZone(.three)
                    let zone4 = zone2Min.hrZone(.four)
                    let zone5 = zone2Min.hrZone(.five)
                    
                    let multiplier = if heartRate >= Double(zone5) {
                        4
                    } else if heartRate >= Double(zone4) {
                        3
                    } else if heartRate >= Double(zone3) {
                        2
                    } else {
                        1
                    }
                    
                    let date = calendar.startOfDay(for: sample.startDate)
                    let value = zone2RecentTemp[date] ?? multiplier
                    if let latest {
                        let timeSinceLastZone2 = (sample.startDate.timeIntervalSince(latest).second * multiplier)
                        if timeSinceLastZone2 < 10 {
                            zone2RecentTemp[date] = value + timeSinceLastZone2
                        } else {
                            zone2RecentTemp[date] = multiplier
                        }
                    } else {
                        zone2RecentTemp[date] = multiplier
                    }
                    
                    latest = sample.startDate
                }
            }
            
            var checking: Date = calendar.startOfDay(for: .now)
            let dayInSeconds: TimeInterval = 86400
            for _ in 0...60 {
                if zone2RecentTemp[checking] != nil {
                    let value = zone2RecentTemp[checking] ?? 0
                    zone2RecentTemp[checking] = Int((Double(value) / 60).rounded())
                } else {
                    zone2RecentTemp[checking] = 0
                }
                checking = checking.addingTimeInterval(-dayInSeconds)
            }
            
            DispatchQueue.main.async {
                self.latestZone2 = latest ?? .distantPast
                self.zone2ByDay = zone2RecentTemp
                self.zone2ByDayLoading = false
            }
        })
        
        if refresh {
            zone2ByDay = [:]
        }
        
        zone2ByDayLoading = true
        
        healthStore.execute(query)
    }

    // MARK: - Resting Heart Rate
    func getRhrRecent() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }

        let startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-hourInSeconds * 24 * 60))
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: .none) { query, results, error in
            guard let samples = results as? [HKQuantitySample] else {
                return
            }

            var latest: Date = .distantPast
            var bestSample: HKQuantitySample?

            var count = 0
            var sum = 0
            var byDay: [Date: Int] = [:]

            let heartRateUnit: HKUnit = HKUnit(from: "count/min")

            let twoWeeksAgo = Calendar.current.startOfDay(for: .now.addingTimeInterval(-hourInSeconds * 24 * 14))

            for sample in samples {
                if sample.endDate > latest {
                    latest = sample.endDate
                    bestSample = sample
                }

                let h = sample.quantity.doubleValue(for: heartRateUnit)

                if sample.endDate < twoWeeksAgo {
                    count += 1
                    sum += Int(h.rounded())
                }

                if let heart = byDay[sample.endDate] {
                    byDay[sample.endDate] = heart + Int(h.rounded())
                } else {
                    byDay[sample.endDate] = Int(h.rounded())
                }
            }

            if let bestSample {
                DispatchQueue.main.async {
                    self.rhrMostRecent = Int(bestSample.quantity.doubleValue(for: heartRateUnit).rounded())
                    self.rhrAverage = Int((Double(sum) / Double(count)).rounded())
                    self.rhrByDay = byDay
                    self.latestRhr = latest
                    self.hasRhrToday = latest.isToday()
                    
                    let stats = self.rhrStats()
                    self.rhrRangeTop = stats.rangeTop
                    self.rhrRangeBottom = stats.rangeBottom
                    self.rhrMeasuredTop = stats.measuredTop
                    self.rhrMeasuredBottom = stats.measuredBottom
                    self.rhrStatus = stats.status
                    
                    self.rhrLoading = false
                }
            }
        }
        
        rhrLoading = true

        healthStore.execute(query)
    }

    // MARK: - Cardio Recovery
    func getRecoveryRecent() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute) else {
            fatalError("*** Unable to create a heart rate type ***")
        }

        let startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-hourInSeconds * 24 * 60))
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: .none) { query, results, error in
            guard let samples = results as? [HKQuantitySample] else {
                return
            }

            var latest: Date = .distantPast
            var bestSample: HKQuantitySample?

            var count = 0
            var sum = 0
            var byDay: [Date: Int] = [:]

            let heartRateUnit: HKUnit = HKUnit(from: "count/min")

            let twoWeeksAgo = Calendar.current.startOfDay(for: .now.addingTimeInterval(-hourInSeconds * 24 * 14))

            for sample in samples {
                if sample.endDate > latest {
                    latest = sample.endDate
                    bestSample = sample
                }

                let h = sample.quantity.doubleValue(for: heartRateUnit)

                if sample.endDate < twoWeeksAgo {
                    count += 1
                    sum += Int(h.rounded())
                }

                if let heart = byDay[sample.endDate] {
                    byDay[sample.endDate] = heart + Int(h.rounded())
                } else {
                    byDay[sample.endDate] = Int(h.rounded())
                }
            }

            if let bestSample {
                DispatchQueue.main.async {
                    self.recoveryMostRecent = Int(bestSample.quantity.doubleValue(for: heartRateUnit).rounded())
                    self.recoveryAverage = Int((Double(sum) / Double(count)).rounded())
                    self.recoveryByDay = byDay
                    self.latestRecovery = bestSample.endDate
                    self.recoveryLoading = false
                }
            }
        }
        
        recoveryLoading = true

        healthStore.execute(query)
    }

    // MARK: - Distance
    func getDistanceFor(_ timeFrame: OTimePeriod) {
        let quantityType = HKQuantityType(.distanceWalkingRunning)
        
        let calendar = Calendar.current
        
        let predicate: NSPredicate
        switch timeFrame {
        case .day:
            let startDate = Calendar.current.startOfDay(for: .now)
            predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: .now,
                options: .strictStartDate
            )
        case .week:
            let todayNumber = calendar.component(.weekday, from: .now)
            let sixDaysAgo = todayNumber == 7 ? 1 : todayNumber + 1
            let components = DateComponents(
                calendar: calendar,
                timeZone: calendar.timeZone,
                hour: 3,
                minute: 0,
                second: 0,
                weekday: sixDaysAgo
            )
            
            guard let anchorDate = calendar.nextDate(
                after: .now,
                matching: components,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .backward
            ) else {
                fatalError("*** unable to find the previous Monday. ***")
            }
            
            predicate = HKQuery.predicateForSamples(
                withStart: anchorDate,
                end: .now,
                options: .strictStartDate
            )
        case .month:
            let monthAgo = calendar.startOfDay(for: .now.addingTimeInterval(-hourInSeconds * 24 * 30))
            
            predicate = HKQuery.predicateForSamples(
                withStart: monthAgo,
                end: .now,
                options: .strictStartDate
            )
        }
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "")")
                return
            }
           
            let unit = UnitLength(forLocale: .current)
            let lengthUnit = unit == UnitLength.feet ? HKUnit.mile() : HKUnit.meter()
            
            let distance = sum.doubleValue(for: lengthUnit)
            
            DispatchQueue.main.async {
                switch timeFrame {
                case .day:
                    self.distanceToday = distance
                case .week:
                    self.distanceWeek = distance
                case .month:
                    self.distanceMonth = distance
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Cardio Fitness
    func getCardioFitnessRecent() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .vo2Max) else {
            fatalError("*** Unable to create a vo2max type ***")
        }
        
        let startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-hourInSeconds * 24 * 60))
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: .none) { query, results, error in
            guard let samples = results as? [HKQuantitySample] else {
                return
            }
            
            var latest: Date = .distantPast
            var bestSample: HKQuantitySample?

            var count = 0
            var sum = 0.0
            var cardioByDay: [Date: Double] = [:]

            let kgmin = HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute())
            let mL = HKUnit.literUnit(with: .milli)
            let vo2Unit = mL.unitDivided(by: kgmin)

            let twoWeeksAgo = Calendar.current.startOfDay(for: .now.addingTimeInterval(-hourInSeconds * 24 * 14))

            for sample in samples {
                if sample.endDate > latest {
                    latest = sample.endDate
                    bestSample = sample
                }

                if sample.endDate < twoWeeksAgo {
                    count += 1
                    sum += sample.quantity.doubleValue(for: vo2Unit)
                }

                if let cardio = cardioByDay[sample.endDate] {
                    let c = (cardio + sample.quantity.doubleValue(for: vo2Unit)) / 2
                    cardioByDay[sample.endDate] = c
                } else {
                    cardioByDay[sample.endDate] = sample.quantity.doubleValue(for: vo2Unit)
                }
            }
            
            if let bestSample {
                DispatchQueue.main.async {
                    self.cardioFitnessMostRecent = bestSample.quantity.doubleValue(for: vo2Unit)
                    self.cardioFitnessAverage = sum / Double(count)
                    self.cardioFitnessByDay = cardioByDay
                    self.latestCardioFitness = bestSample.endDate
                    self.cardioFitnessLoading = false
                }
            }
        }
        
        cardioFitnessLoading = true
        
        healthStore.execute(query)
    }
    
    // MARK: - Mindful Minutes
    func getMindfulMinutesFor(_ timeFrame: OTimePeriod) {
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        let calendar = Calendar.current
        
        let predicate: NSPredicate
        switch timeFrame {
        case .day:
            let startDate = Calendar.current.startOfDay(for: .now)
            predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: .now,
                options: .strictStartDate
            )
        case .week:
            // Set the anchor for 3 a.m. 6 days ago.
            let todayNumber = calendar.component(.weekday, from: .now)
            let sixDaysAgo = todayNumber == 7 ? 1 : todayNumber + 1
            let components = DateComponents(
                calendar: calendar,
                timeZone: calendar.timeZone,
                hour: 3,
                minute: 0,
                second: 0,
                weekday: sixDaysAgo
            )
            
            guard let anchorDate = calendar.nextDate(
                after: .now,
                matching: components,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .backward
            ) else {
                fatalError("*** unable to find the previous Monday. ***")
            }
            
            predicate = HKQuery.predicateForSamples(
                withStart: anchorDate,
                end: .now,
                options: .strictStartDate
            )
        case .month:
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples else {
                if let error {
                    print(error.localizedDescription)
                }
                return
            }
            
            var total = TimeInterval()
            var latest: Date = .distantPast
            for sample in samples {
                total += sample.endDate.timeIntervalSince(sample.startDate)
                
                if sample.endDate > latest {
                    latest = sample.endDate
                }
            }
            
            DispatchQueue.main.async {
                let minutes = Int((total / 60).rounded())
                
                switch timeFrame {
                case .day:
                    self.mindfulMinutesToday = minutes
                case .week:
                    self.mindfulMinutesWeek = minutes
                case .month:
                    return
                }
                
                self.latestMindfulMinutes = latest
            }
        }

        healthStore.execute(query)
    }
    
    func getMindfulMinutesDayByHour(refresh: Bool = false) {
        self.mindfulMinutesDayByHourLoading = true
        
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        let calendar = Calendar.current
        
        let anchorDate = calendar.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(
            withStart: anchorDate,
            end: .now,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard error == nil else {
                print("error")
                return
            }
            
            var mindfulMinutesDayByHourTemp: [Date: Int] = [:]
            for (_, sample) in samples!.enumerated() {
                let date = sample.startDate.topOfTheHour()
                let seconds = Int(sample.endDate.timeIntervalSince(sample.startDate))
                
                if mindfulMinutesDayByHourTemp[date] != nil {
                    let prevValue = mindfulMinutesDayByHourTemp[date] ?? 0
                    mindfulMinutesDayByHourTemp[date] = prevValue + seconds
                } else {
                    mindfulMinutesDayByHourTemp[date] = seconds
                }
            }
            
            for i in 1...24 {
                let hour = Date.now.getTodayAtHour(i)
                let value = Int((Double(mindfulMinutesDayByHourTemp[hour] ?? 0) / 60).rounded())
                mindfulMinutesDayByHourTemp[hour] = value
            }
            
            DispatchQueue.main.async {
                self.mindfulMinutesDayByHour = mindfulMinutesDayByHourTemp
                self.mindfulMinutesDayByHourLoading = false
            }
        }
        
        if refresh {
            mindfulMinutesWeekByDay = [:]
        }
        
        healthStore.execute(query)
    }
    
    func getMindfulMinutesWeekByDay(refresh: Bool = false) {
        self.mindfulMinutesWeekByDayLoading = true
        
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        let calendar = Calendar.current
        
        // Set the anchor for 3 a.m. 6 days ago.
        let todayNumber = calendar.component(.weekday, from: .now)
        let sixDaysAgo = todayNumber == 7 ? 1 : todayNumber + 1
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            hour: 3,
            minute: 0,
            second: 0,
            weekday: sixDaysAgo
        )
        
        guard let anchorDate = calendar.nextDate(
            after: .now,
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .backward
        ) else {
            fatalError("*** unable to find the previous Monday. ***")
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: anchorDate,
            end: .now,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples else {
                if let error {
                    print(error.localizedDescription)
                }
                return
            }
            
            var mindfulMinutesWeekByDayTemp: [Date: Int] = [:]
            let today: Date = .now
            for i in 0...6 {
                let date = calendar.date(byAdding: .day, value: -i, to: today)
                if let date {
                    mindfulMinutesWeekByDayTemp[date] = 0
                }
            }
            
            for (day, _) in mindfulMinutesWeekByDayTemp {
                var total = TimeInterval()
                
                for sample in samples {
                    if calendar.isDate(sample.startDate, inSameDayAs: day) {
                        total += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }
                
                mindfulMinutesWeekByDayTemp[day] = Int((total / 60).rounded())
            }
            
            DispatchQueue.main.async {
                self.mindfulMinutesWeekByDay = mindfulMinutesWeekByDayTemp
                self.mindfulMinutesWeekByDayLoading = false
            }
        }
        
        if refresh {
            mindfulMinutesWeekByDay = [:]
        }
        
        healthStore.execute(query)
    }
    
    func setMindfulMinutes(seconds: Int, date: Date) {
        let mindfulType = HKCategoryType(.mindfulSession)
        
        let endDate = Calendar.current.date(byAdding: .second, value: seconds, to: date) ?? .now
        let mindfulSample = HKCategorySample(type: mindfulType, value: HKCategoryValue.notApplicable.rawValue, start: date, end: endDate)
        
        healthStore.save(mindfulSample, withCompletion: { (success, error) -> Void in
            if success {
                self.getMindfulMinutesFor(.day)
                self.getMindfulMinutesFor(.week)
            } else {
                // Something wrong
                if let error {
                    print(error.localizedDescription)
                }
            }
            
        })
    }
    
    // MARK: - Body temp
    func getBodyTempToday() {
        bodyTempLoading = true
        
        let quantityType = HKQuantityType(.appleSleepingWristTemperature)
        
        let calendar = Calendar.current
        
        // Begin looking 3 hours before midnight of today
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 3)
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, error in
            guard let result = result else {
                print("failed to read body temp: \(error?.localizedDescription ?? "")")
                return
            }
            
            let averageTemp = result.averageQuantity()
            
            let metricOrImperial = UnitLength(forLocale: .current)
            let unit = metricOrImperial == .feet ? HKUnit.degreeFahrenheit() : HKUnit.degreeCelsius()
            
            let bodyTemp = averageTemp?.doubleValue(for: unit)
            let lastUpdated = result.endDate
            
            DispatchQueue.main.async {
                if lastUpdated.isToday() {
                    self.bodyTempToday = bodyTemp ?? 0
                    self.bodyTempLastUpdated = lastUpdated
                    self.hasBodyTempToday = true
                } else {
                    self.hasBodyTempToday = false
                }
                
                self.bodyTempLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    func getBodyTempTwoWeeks() {
        bodyTempByDayLoading = true
        
        let quantityType = HKQuantityType(.appleSleepingWristTemperature)
        
        let calendar = Calendar.current
        
        // Begin looking 3 hours before midnight of 14 days ago
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 339)
        
        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .discreteAverage,
            anchorDate: start,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                assertionFailure("")
                return
            }
            
            let end = Date.now
            
            let metricOrImperial = UnitLength(forLocale: .current)
            let unit = metricOrImperial == .feet ? HKUnit.degreeFahrenheit() : HKUnit.degreeCelsius()
            
            var bodyTempByDayTemp: [Date: Double] = [:]
            statsCollection.enumerateStatistics(from: start, to: end) { (statistics, stop) in
                if let quantity = statistics.averageQuantity() {
                    let bodyTemp = quantity.doubleValue(for: unit)
                    let date = statistics.endDate
                    
                    bodyTempByDayTemp[date] = bodyTemp
                }
            }
            
            DispatchQueue.main.async {
                self.bodyTempByDay = bodyTempByDayTemp
                
                let stats = self.tempStats()
                self.bodyTempRangeTop = stats.rangeTop
                self.bodyTempRangeBottom = stats.rangeBottom
                self.bodyTempMeasuredTop = stats.measuredTop
                self.bodyTempMeasuredBottom = stats.measuredBottom
                self.bodyTempStatus = stats.status
                
                self.bodyTempByDayLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    
    // MARK: - Respiration
    func getRespirationToday() {
        respirationLoading = true
        
        let quantityType = HKQuantityType(.respiratoryRate)
        
        let calendar = Calendar.current
        
        // Begin looking 3 hours before midnight of today
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 3)
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, error in
            guard let result = result else {
                print("failed to read body temp: \(error?.localizedDescription ?? "")")
                return
            }
            
            let averageRespiration = result.averageQuantity()
            
            let respirationTemp = averageRespiration?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            let lastUpdated = result.endDate
            
            DispatchQueue.main.async {
                if lastUpdated.isToday() {
                    self.respirationToday = respirationTemp ?? 0
                    self.respirationLastUpdated = lastUpdated
                    self.hasRespirationToday = true
                } else {
                    self.hasRespirationToday = false
                }
                
                self.respirationLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    func getRespirationTwoWeeks() {
        respirationByDayLoading = true
        
        let quantityType = HKQuantityType(.respiratoryRate)
        
        let calendar = Calendar.current
        
        // Begin looking 3 hours before midnight of 14 days ago
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 339)
        
        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .discreteAverage,
            anchorDate: start,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                assertionFailure("")
                return
            }
            
            let end = Date.now
            
            var respirationByDayTemp: [Date: Double] = [:]
            statsCollection.enumerateStatistics(from: start, to: end) { (statistics, stop) in
                if let quantity = statistics.averageQuantity() {
                    let respiration = quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    let date = statistics.endDate
                    
                    respirationByDayTemp[date] = respiration
                }
            }
            
            DispatchQueue.main.async {
                self.respirationByDay = respirationByDayTemp
                
                let stats = self.respirationStats()
                self.respirationRangeTop = stats.rangeTop
                self.respirationRangeBottom = stats.rangeBottom
                self.respirationMeasuredTop = stats.measuredTop
                self.respirationMeasuredBottom = stats.measuredBottom
                self.respirationStatus = stats.status
                
                self.respirationByDayLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Blood oxygen
    func getOxygenToday() {
        oxygenLoading = true
        
        let quantityType = HKQuantityType(.oxygenSaturation)
        
        let calendar = Calendar.current
        
        // Begin looking 3 hours before midnight of today
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 3)
        var end = calendar.startOfDay(for: .now).addingTimeInterval(hourInSeconds * 8)
        if end.compare(Date.now) == .orderedDescending {
            end = .now
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, error in
            guard let result = result else {
                print("failed to read body temp: \(error?.localizedDescription ?? "")")
                return
            }
            
            let averageOxygen = result.averageQuantity()
            
            let oxygenTemp = averageOxygen?.doubleValue(for: HKUnit.percent())
            let lastUpdated = result.endDate
            
            DispatchQueue.main.async {
                if lastUpdated.isToday() {
                    if let oxygenTemp {
                        self.oxygenToday = (oxygenTemp * 100).rounded(toPlaces: 1)
                    }
                    self.oxygenLastUpdated = lastUpdated
                    self.hasOxygenToday = true
                } else {
                    self.hasOxygenToday = false
                }
                
                self.oxygenLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    func getOxygenTwoWeeks() {
        oxygenByDayLoading = true
        
        let quantityType = HKQuantityType(.oxygenSaturation)
        
        let calendar = Calendar.current
        
        // Begin looking 3 hours before midnight of 14 days ago
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 339)

        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .discreteAverage,
            anchorDate: start,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                assertionFailure("")
                return
            }
            
            let end = calendar.startOfDay(for: .now).addingTimeInterval(hourInSeconds * 10)
            
            var oxygenByDayTemp: [Date: Double] = [:]
            statsCollection.enumerateStatistics(from: start, to: end) { (statistics, stop) in
                if let quantity = statistics.averageQuantity() {
                    let oxygen = quantity.doubleValue(for: HKUnit.percent())
                    let date = statistics.endDate
                    
                    oxygenByDayTemp[date] = (oxygen * 100).rounded(toPlaces: 1)
                }
            }
            
            DispatchQueue.main.async {
                self.oxygenByDay = oxygenByDayTemp
                
                let stats = self.oxygenStats()
                self.oxygenRangeTop = stats.rangeTop
                self.oxygenRangeBottom = stats.rangeBottom
                self.oxygenMeasuredTop = stats.measuredTop
                self.oxygenMeasuredBottom = stats.measuredBottom
                self.oxygenStatus = stats.status
                
                self.oxygenByDayLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Heart rate variability
    func getHrvToday() {
        hrvLoading = true
        
        let quantityType = HKQuantityType(.heartRateVariabilitySDNN)
        
        let calendar = Calendar.current
        
        // Begin looking 2 hours before midnight of today
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 2)
        var end = calendar.startOfDay(for: .now).addingTimeInterval(hourInSeconds * 8)
        if end.compare(Date.now) == .orderedDescending {
            end = .now
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, result, error in
            guard let result = result else {
                print("failed to read body temp: \(error?.localizedDescription ?? "")")
                return
            }
            
            let averageHrv = result.averageQuantity()
            
            let hrv = averageHrv?.doubleValue(for: HKUnit.second())
            let lastUpdated = result.endDate
            
            DispatchQueue.main.async {
                if lastUpdated.isToday() {
                    if let hrv {
                        self.hrvToday = hrv * 1000
                    }
                    self.hrvLastUpdated = lastUpdated
                    self.hasHrvToday = true
                } else {
                    self.hasHrvToday = false
                }
                
                self.hrvLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    func getHrvTwoWeeks() {
        hrvByDayLoading = true
        
        let quantityType = HKQuantityType(.heartRateVariabilitySDNN)
        
        let calendar = Calendar.current
        
        // Begin looking 2 hours before midnight of 14 days ago
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-hourInSeconds * 338)
        
        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .discreteAverage,
            anchorDate: start,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, results, error in
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let statsCollection = results else {
                assertionFailure("")
                return
            }
            
            let end = Date.now
            
            var hrvByDayTemp: [Date: Double] = [:]
            statsCollection.enumerateStatistics(from: start, to: end) { (statistics, stop) in
                if let quantity = statistics.averageQuantity() {
                    let hrv = quantity.doubleValue(for: HKUnit.second())
                    let date = statistics.endDate
                    
                    hrvByDayTemp[date] = hrv * 1000
                }
            }
            
            DispatchQueue.main.async {
                self.hrvByDay = hrvByDayTemp
                
                let stats = self.hrvStats()
                self.hrvRangeTop = stats.rangeTop
                self.hrvRangeBottom = stats.rangeBottom
                self.hrvMeasuredTop = stats.measuredTop
                self.hrvMeasuredBottom = stats.measuredBottom
                self.hrvStatus = stats.status
                
                self.hrvByDayLoading = false
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Sleep
    func getSleepToday() {
        sleepLoading = true
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let start = startOfDay.addingTimeInterval(-hourInSeconds * 7)
        let end = now.compare(startOfDay.addingTimeInterval(hourInSeconds * 10)) == .orderedDescending ? now : startOfDay.addingTimeInterval(hourInSeconds * 10)

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                print("Error fetching sleep data: \(error.localizedDescription)")
                return
            }

            var duration = 0.0
            if let sleepSamples = samples as? [HKCategorySample] {
                duration = self.sleepDurationHoursForSamples(sleepSamples)
            }
            
            DispatchQueue.main.async {
                self.sleepToday = duration
                self.hasSleepToday = duration != 0
                self.sleepLoading = false
            }
        }

        healthStore.execute(query)
    }
    
    func getSleepTwoWeeks() {
        sleepByDayLoading = true
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let start = startOfDay.addingTimeInterval(-hourInSeconds * 31 * 14)
        let end = startOfDay.addingTimeInterval(hourInSeconds * 10)

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                print("Error fetching sleep data: \(error.localizedDescription)")
                return
            }

            var duration = 0.0
            var samplesAndDays: [Date: [HKCategorySample]] = [:]
            var sleepByDayTemp: [Date: Double] = [:]
            
            for day in 0...14 {
                let date = calendar.startOfDay(for: now).addingTimeInterval(-hourInSeconds * 24 * Double(day))
                samplesAndDays[date] = []
            }
            
            if let sleepSamples = samples as? [HKCategorySample] {
                for sample in sleepSamples {
                    for (d, _) in samplesAndDays {
                        if sample.startDate.isPartOf(day: d) {
                            samplesAndDays[d]?.append(sample)
                        }
                    }
                }
                
                for (d, samples) in samplesAndDays {
                    duration = self.sleepDurationHoursForSamples(samples)
                    sleepByDayTemp[d] = duration
                }
            }
            
            DispatchQueue.main.async {
                self.sleepByDay = sleepByDayTemp
                
                let stats = self.sleepStats()
                self.sleepRangeTop = stats.rangeTop
                self.sleepRangeBottom = stats.rangeBottom
                self.sleepMeasuredTop = stats.measuredTop
                self.sleepMeasuredBottom = stats.measuredBottom
                self.sleepStatus = stats.status
                
                self.sleepByDayLoading = false
            }
        }

        healthStore.execute(query)
    }
    
    private func sleepDurationHoursForSamples(_ samples: [HKCategorySample]) -> Double {
        let sources = Set(samples.map { $0.sourceRevision.productType ?? "" })
        var watchOnly = false
        for source in sources {
            if source.lowercased().contains("watch") {
                watchOnly = true
                break
            }
        }
        
        var duration = 0.0
        for sample in samples {
            if watchOnly {
                if !(sample.sourceRevision.productType?.lowercased().contains("watch") ?? false) {
                    continue
                }
            }
            
            if let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                let startDate = sample.startDate
                let endDate = sample.endDate

                switch sleepValue {
                case .awake, .inBed:
                    // Do nothing
                    break
                case .asleepCore, .asleepDeep, .asleepREM:
                    duration += (endDate.timeIntervalSince(startDate) / 60 / 60)
                default:
                    duration += (endDate.timeIntervalSince(startDate) / 60 / 60)
                }
            }
        }
        
        return duration
    }
    
    // MARK: - Helpers
    private func tempStats() -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 150.0
        
        var average = 0.0
        for (_, temp) in self.bodyTempByDay {
            average += temp
            
            if temp < measuredBottom {
                measuredBottom = temp
            }
            
            if temp > measuredTop {
                measuredTop = temp
            }
        }
        
        average /= Double(self.bodyTempByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if self.bodyTempToday < rangeBottom {
            .low
        } else if self.bodyTempToday > rangeTop {
            .high
        } else {
            .normal
        }
        
        if !self.hasBodyTempToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    private func hrvStats() -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 250.0
        
        var average = 0.0
        for (_, hrv) in self.hrvByDay {
            average += hrv
            
            if hrv < measuredBottom {
                measuredBottom = hrv
            }
            
            if hrv > measuredTop {
                measuredTop = hrv
            }
        }
        
        average /= Double(self.hrvByDay.count)
        
        rangeBottom = average - 10
        rangeTop = average + 10
        
        var status: BodyMetricStatus = if self.hrvToday < rangeBottom {
            .low
        } else if self.hrvToday > rangeTop && self.hrvToday <= rangeTop + 10 {
            .optimal
        } else if self.hrvToday > rangeTop + 10 {
            .high
        } else {
            .normal
        }
        
        if !self.hasHrvToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
        
    private func oxygenStats() -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 110.0
        
        var average = 0.0
        for (_, oxygen) in self.oxygenByDay {
            average += oxygen
            
            if oxygen < measuredBottom {
                measuredBottom = oxygen
            }
            
            if oxygen > measuredTop {
                measuredTop = oxygen
            }
        }
        
        average /= Double(self.oxygenByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if self.oxygenToday < rangeBottom {
            .low
        } else if self.oxygenToday > rangeTop && self.oxygenToday <= rangeTop + 1 {
            .optimal
        } else if self.oxygenToday > rangeTop + 1 {
            .high
        } else {
            .normal
        }
        
        if !self.hasOxygenToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    private func respirationStats() -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 110.0
        
        var average = 0.0
        for (_, respiration) in self.respirationByDay {
            average += respiration
            
            if respiration < measuredBottom {
                measuredBottom = respiration
            }
            
            if respiration > measuredTop {
                measuredTop = respiration
            }
        }
        
        average /= Double(self.respirationByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if self.respirationToday < rangeBottom - 1 {
            .low
        } else if self.respirationToday < rangeBottom && self.respirationToday >= rangeBottom - 1 {
            .optimal
        } else if self.respirationToday > rangeTop {
            .high
        } else {
            .normal
        }
        
        if !self.hasRespirationToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    private func rhrStats() -> (rangeTop: Int, rangeBottom: Int, measuredTop: Int, measuredBottom: Int, status: BodyMetricStatus) {
        var rangeTop: Int = 0
        var rangeBottom: Int = 0
        var measuredTop: Int = 0
        var measuredBottom: Int = 200
        
        var average = 0
        for (_, rhr) in self.rhrByDay {
            average += rhr
            
            if rhr < measuredBottom {
                measuredBottom = rhr
            }
            
            if rhr > measuredTop {
                measuredTop = rhr
            }
        }
        
        average = Int((Double(average) / Double(self.rhrByDay.count)).rounded(toPlaces: 0))
        
        rangeBottom = average - 3
        rangeTop = average + 3
        
        var status: BodyMetricStatus = if self.rhrMostRecent < rangeBottom - 3 {
            .low
        } else if self.rhrMostRecent < rangeBottom && self.rhrMostRecent >= rangeBottom - 3 {
            .optimal
        } else if self.rhrMostRecent > rangeTop {
            .high
        } else {
            .normal
        }
        
        if !self.hasRhrToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
    
    private func sleepStats() -> (rangeTop: Double, rangeBottom: Double, measuredTop: Double, measuredBottom: Double, status: BodyMetricStatus) {
        var rangeTop: Double = 0
        var rangeBottom: Double = 0
        var measuredTop: Double = 0
        var measuredBottom: Double = 24
        
        var average = 0.0
        for (_, sleep) in self.sleepByDay {
            average += sleep
            
            if sleep < measuredBottom {
                measuredBottom = sleep
            }
            
            if sleep > measuredTop {
                measuredTop = sleep
            }
        }
        
        average /= Double(self.sleepByDay.count)
        
        rangeBottom = average - 1
        rangeTop = average + 1
        
        var status: BodyMetricStatus = if self.sleepToday < rangeBottom {
            .low
        } else if self.sleepToday > rangeTop && self.sleepToday <= rangeTop + 1 {
            .optimal
        } else if self.sleepToday > rangeTop + 1 {
            .high
        } else {
            .normal
        }
        
        if !self.hasSleepToday {
            status = .missing
        }
        
        return (rangeTop: rangeTop, rangeBottom: rangeBottom, measuredTop: measuredTop, measuredBottom: measuredBottom, status: status)
    }
}
