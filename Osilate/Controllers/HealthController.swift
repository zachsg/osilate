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
    var stepCountHourly: [Int: Int] = [:]
    var stepCountWeekByDay: [Date: Int] = [:]
    var latestSteps: Date = .now
    
    // Zone 2
    var zone2Today = 0
    var zone2Week = 0
    var zone2Hourly: [Int: Int] = [:]
    var zone2WeekByDay: [Date: Int] = [:]
    var zone2ByDay: [Date: Int] = [:]
    var latestZone2: Date = .now

    // Walk/run distance
    var walkRunDistanceToday = 0.0
    var latestWalkRunDistance: Date = .now
    
    // VO2 max
    var cardioFitnessMostRecent = 0.0
    var cardioFitnessAverage = 0.0
    var cardioFitnessByDay: [Date: Double] = [:]
    var latestCardioFitness: Date = .now

    // Resting heart rate
    var rhrMostRecent = 0
    var rhrAverage = 0
    var rhrByDay: [Date: Int] = [:]
    var latestRhr: Date = .now

    // Cardio recovery
    var recoveryMostRecent = 0
    var recoveryAverage = 0
    var recoveryByDay: [Date: Int] = [:]
    var latestRecovery: Date = .now
    
    // Mindful Minutes
    var mindfulMinutesToday = 0
    var latestMindfulMinutes: Date = .now
    var mindfulMinutesWeek = 0
    var mindfulMinutesWeekByDay: [Date: Int] = [:]
    
    // Body temp
    var bodyTempLoading = false
    var bodyTempToday = 0.0
    var bodyTempByDayLoading = false
    var bodyTempByDay: [Date: Double] = [:]
    var hasBodyTempToday = false
    var bodyTempLastUpdated: Date = .now
    
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
            HKQuantityType(.appleSleepingWristTemperature)
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
    func getStepCountToday() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        let startDate = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )
        
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
                self.stepCountToday = steps
                self.latestSteps = result.endDate
            }
        }
        
        healthStore.execute(query)
    }
    
    func getStepCountWeek() {
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
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: anchorDate,
            end: .now,
            options: .strictStartDate
        )
        
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
                self.stepCountWeek = steps
            }
        }
        
        healthStore.execute(query)
    }
    
    func getStepCountWeekByDay(refresh: Bool = false) {
        let calendar = Calendar.current
        
        // Create a 1-week interval.
        let interval = DateComponents(day: 1)
        
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
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .backward
        ) else {
            fatalError("*** unable to find the previous Monday. ***")
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
                
        // Create the query.
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        
        // Set the results handler.
        query.initialResultsHandler = { query, results, error in
            // Handle errors here.
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
                // You should only hit this case if you have an unhandled error. Check for bugs
                // in your code that creates the query, or explicitly handle the error.
                assertionFailure("")
                return
            }
            
            let endDate = Date()
            let oneWeekAgo = DateComponents(day: -6)
            
            guard let startDate = calendar.date(byAdding: oneWeekAgo, to: endDate) else {
                fatalError("*** Unable to calculate the start date ***")
            }
            
            // Enumerate over all the statistics objects between the start and end dates.
            var stepCountWeekByDayTemp: [Date: Int] = [:]
            statsCollection.enumerateStatistics(from: startDate, to: endDate)
            { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: .count())
                    
                    stepCountWeekByDayTemp[date] = Int(value)
                }
            }
            
            // Dispatch to the main queue to update the UI.
            DispatchQueue.main.async {
                self.stepCountWeekByDay = stepCountWeekByDayTemp
            }
        }
        
//        query.statisticsUpdateHandler = { query, statistics, collection, error in
//            guard let collection else {
//                print("no collection found")
//                return
//            }
//
//            let endDate = Date()
//            let oneWeekAgo = DateComponents(day: -6)
//            guard let startDate = calendar.date(byAdding: oneWeekAgo, to: endDate) else {
//                fatalError("*** Unable to calculate the start date ***")
//            }
//
//            collection.enumerateStatistics(from: startDate, to: Date()){ (statistics, stop) in
//                guard let quantity = statistics.sumQuantity() else {
//                    return
//                }
//
//                let date = statistics.startDate
//                let value = quantity.doubleValue(for: .count())
//
//                self.stepCountWeekByDay[date] = Int(value)
//
//                DispatchQueue.main.async {
//                    // Update UI
//                }
//            }
//        }
        
        if refresh {
            stepCountWeekByDay = [:]
        }
        
        healthStore.execute(query)
    }
    
    func getStepCountHourly(refresh: Bool = false) {
        let calendar = Calendar.current
        
        // Create a 1-week interval.
        let interval = DateComponents(hour: 1)
        
        let anchorDate = calendar.startOfDay(for: Date())
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
                
        // Create the query.
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        
        // Set the results handler.
        query.initialResultsHandler = { query, results, error in
            // Handle errors here.
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
                // You should only hit this case if you have an unhandled error. Check for bugs
                // in your code that creates the query, or explicitly handle the error.
                assertionFailure("")
                return
            }
            
            // Enumerate over all the statistics objects between the start and end dates.
            var stepCountHourlyTemp: [Int: Int] = [:]
            statsCollection.enumerateStatistics(from: anchorDate, to: Date())
            { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let hour = calendar.component(.hour, from: statistics.startDate)
                    let value = quantity.doubleValue(for: .count())
                    
                    stepCountHourlyTemp[hour] = Int(value)
                }
            }
            
            // Dispatch to the main queue to update the UI.
            DispatchQueue.main.async {
                self.stepCountHourly = stepCountHourlyTemp
            }
        }
        
        if refresh {
            stepCountHourly = [:]
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Zone 2
    func getZone2Today() {
        @AppStorage(zone2MinKey) var zone2Min: Int = zone2MinDefault
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }
        
        let heartRateUnit:HKUnit = HKUnit(from: "count/min")
        
        let startDate = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )
        
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
                    if let latest {
                        let timeSinceLastZone2 = sample.startDate.timeIntervalSince(latest).second
                        if timeSinceLastZone2 < 120 {
                            total += timeSinceLastZone2
                        } else {
                            total += 1
                        }
                    } else {
                        total += 1
                    }
                    
                    latest = sample.startDate
                }
            }
            
            DispatchQueue.main.async {
                self.zone2Today = Int((Double(total) / 60).rounded())

                if latest != .distantPast {
                    self.latestZone2 = latest ?? .distantPast
                }
            }
        })
        
        healthStore.execute(query)
    }
    
    func getZone2Week() {
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
            
            var total = 0
            var latest: Date?
            for (_, sample) in results!.enumerated() {
                guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
                
                let heartRate = currData.quantity.doubleValue(for: heartRateUnit)
                if heartRate >= Double(zone2Min) {
                    if let latest {
                        let timeSinceLastZone2 = sample.startDate.timeIntervalSince(latest).second
                        if timeSinceLastZone2 < 120 {
                            total += timeSinceLastZone2
                        } else {
                            total += 1
                        }
                    } else {
                        total += 1
                    }
                    
                    latest = sample.startDate
                }
            }
            
            DispatchQueue.main.async {
                self.zone2Week = Int((Double(total) / 60).rounded())

                if latest != .distantPast {
                    self.latestZone2 = latest ?? .distantPast
                }
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
                    let date = calendar.startOfDay(for: sample.startDate)
                    let value = zone2WeekByDayTemp[date] ?? 0
                    if let latest {
                        let timeSinceLastZone2 = sample.startDate.timeIntervalSince(latest).second
                        if timeSinceLastZone2 < 120 {
                            zone2WeekByDayTemp[date] = value + timeSinceLastZone2
                        } else {
                            zone2WeekByDayTemp[date] = value + 1
                        }
                    } else {
                        zone2WeekByDayTemp[date] = value + 1
                    }
                    
                    latest = sample.startDate
                }
            }
            
            var checking: Date = calendar.startOfDay(for: .now)
            let dayInSeconds: TimeInterval = 86400
            for _ in 1...7 {
                if zone2WeekByDayTemp[checking] != nil {
                    let value = zone2WeekByDayTemp[checking] ?? 0
                    zone2WeekByDayTemp[checking] = Int((Double(value) / 60).rounded())
                } else {
                    zone2WeekByDayTemp[checking] = 0
                }
                checking = checking.addingTimeInterval(-dayInSeconds)
            }
            
            DispatchQueue.main.async {
                self.latestZone2 = latest ?? .distantPast
                self.zone2WeekByDay = zone2WeekByDayTemp
            }
        })
        
        if refresh {
            zone2WeekByDay = [:]
        }
        
        healthStore.execute(query)
    }
    
    func getZone2Hourly(refresh: Bool = false) {
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
            var zone2HourlyTemp: [Int: Int] = [:]
            for (_, sample) in results!.enumerated() {
                guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
                
                let heartRate = currData.quantity.doubleValue(for: heartRateUnit)
                if heartRate >= Double(zone2Min) {
                    let hour = calendar.component(.hour, from: sample.startDate)
                    let value = zone2HourlyTemp[hour] ?? 0
                    if let latest {
                        let timeSinceLastZone2 = sample.startDate.timeIntervalSince(latest).second
                        if timeSinceLastZone2 < 120 {
                            zone2HourlyTemp[hour] = value + timeSinceLastZone2
                        } else {
                            zone2HourlyTemp[hour] = value + 1
                        }
                    } else {
                        zone2HourlyTemp[hour] = value + 1
                    }
                    
                    latest = sample.startDate
                }
            }
            
            let hour = calendar.component(.hour, from: .now)
            for i in 1...hour {
                if zone2HourlyTemp[i] != nil {
                    let value = zone2HourlyTemp[i] ?? 0
                    zone2HourlyTemp[i] = Int((Double(value) / 60).rounded())
                } else {
                    zone2HourlyTemp[i] = 0
                }
            }
            
            DispatchQueue.main.async {
                self.latestZone2 = latest ?? .distantPast
                self.zone2Hourly = zone2HourlyTemp
            }
        })
        
        if refresh {
            zone2Hourly = [:]
        }
        
        healthStore.execute(query)
    }


    func getZone2Recent() {
        @AppStorage(zone2MinKey) var zone2Min: Int = zone2MinDefault

        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }

        let heartRateUnit:HKUnit = HKUnit(from: "count/min")

        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]

        let calendar = Calendar.current

        let startDate = calendar.startOfDay(for: .now.addingTimeInterval(-5148000))
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )

        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard error == nil else {
                print("error")
                return
            }

            var latest: Date = .distantPast
            var usedComponents: [DateComponents] = []

            var zone2ByDayTemp: [Date: Int] = [:]
            for (_, sample) in results!.enumerated() {
                guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }

                let heartRate = currData.quantity.doubleValue(for: heartRateUnit)
                if heartRate >= Double(zone2Min) {
                    let components = sample.startDate.get(.minute, .hour, .day)
                    if !usedComponents.contains(components) {
                        usedComponents.append(components)
                        let date = calendar.startOfDay(for: sample.startDate)
                        let value = zone2ByDayTemp[date] ?? 0
                        zone2ByDayTemp[date] = value + 60
                    }

                    if sample.endDate > latest {
                        latest = sample.endDate
                    }
                }
            }

            var checking: Date = calendar.startOfDay(for: .now)
            let dayInSeconds: TimeInterval = 86400
            for _ in 1...60 {
                if zone2ByDayTemp[checking] != nil {
                    let value = zone2ByDayTemp[checking] ?? 0
                    zone2ByDayTemp[checking] = Int((Double(value) / 60).rounded())
                } else {
                    zone2ByDayTemp[checking] = 0
                }
                checking = checking.addingTimeInterval(-dayInSeconds)
            }

            DispatchQueue.main.async {
                self.latestZone2 = latest
                self.zone2ByDay = zone2ByDayTemp
            }
        })

        healthStore.execute(query)
    }

    // MARK: - Resting Heart Rate
    func getRhrRecent() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            fatalError("*** Unable to create a heart rate type ***")
        }

        let startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-5148000))
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

            let twoWeeksAgo = Calendar.current.startOfDay(for: .now.addingTimeInterval(-1209600))

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
                    self.latestRhr = bestSample.endDate
                }
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Cardio Recovery
    func getRecoveryRecent() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .heartRateRecoveryOneMinute) else {
            fatalError("*** Unable to create a heart rate type ***")
        }

        let startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-5148000))
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

            let twoWeeksAgo = Calendar.current.startOfDay(for: .now.addingTimeInterval(-1209600))

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
                }
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Distance
    func getWalkRunDistanceToday() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("*** Unable to create a distance type ***")
        }
        
        let startDate = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: .now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed to read step count: \(error?.localizedDescription ?? "")")
                return
            }
           
            let desiredLengthUnit = UnitLength(forLocale: .current)
            let lengthUnit = desiredLengthUnit == UnitLength.feet ? HKUnit.mile() : HKUnit.meter()
            
            // TODO: Fix to work with Km and not just Miles
            let distance = sum.doubleValue(for: lengthUnit)
            
            DispatchQueue.main.async {
                self.walkRunDistanceToday = distance
                self.latestWalkRunDistance = result.endDate
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Cardio Fitness
    func getCardioFitnessRecent() {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .vo2Max) else {
            fatalError("*** Unable to create a vo2max type ***")
        }
        
        let startDate = Calendar.current.startOfDay(for: .now.addingTimeInterval(-5148000))
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

            let twoWeeksAgo = Calendar.current.startOfDay(for: .now.addingTimeInterval(-1209600))

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
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Mindful Minutes
    func getMindfulMinutesToday() {
        guard let sampleType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        let startDate = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
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
            
            var total = TimeInterval()
            var latest: Date = .distantPast
            for sample in samples {
                total += sample.endDate.timeIntervalSince(sample.startDate)
                
                if sample.endDate > latest {
                    latest = sample.endDate
                }
            }
            
            DispatchQueue.main.async {
                self.mindfulMinutesToday = Int((total / 60).rounded())
                self.latestMindfulMinutes = latest
            }
        }

        healthStore.execute(query)
    }
    
    func getMindfulMinutesWeek() {
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
            
            var total = TimeInterval()
            var latest: Date = .distantPast
            for sample in samples {
                total += sample.endDate.timeIntervalSince(sample.startDate)
                
                if sample.endDate > latest {
                    latest = sample.endDate
                }
            }
            
            DispatchQueue.main.async {
                self.mindfulMinutesWeek = Int((total / 60).rounded())
                self.latestMindfulMinutes = latest
            }
        }

        healthStore.execute(query)
    }
    
    func getMindfulMinutesWeekByDay(refresh: Bool = false) {
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
            }
        }
        
        if refresh {
            mindfulMinutesWeekByDay = [:]
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Mindful Minutes
    func setMindfulMinutes(seconds: Int, date: Date) {
        let mindfulType = HKCategoryType(.mindfulSession)
        
        let endDate = Calendar.current.date(byAdding: .second, value: seconds, to: date) ?? .now
        let mindfulSample = HKCategorySample(type: mindfulType, value: HKCategoryValue.notApplicable.rawValue, start: date, end: endDate)
        
        healthStore.save(mindfulSample, withCompletion: { (success, error) -> Void in
            if success {
                self.getMindfulMinutesToday()
                self.getMindfulMinutesWeek()
            } else {
                // Something wrong
                if let error {
                    print(error.localizedDescription)
                }
            }
            
        })
    }
    
    // MARK: - Body temp
    func loadBodyTempToday() {
        bodyTempLoading = true
        
        let quantityType = HKQuantityType(.appleSleepingWristTemperature)
        
        let calendar = Calendar.current
        
        // Begin looking for body temp 6 hours before midnight of today
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-21600)
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .mostRecent
        ) { _, result, error in
            guard let result = result else {
                print("failed to read body temp: \(error?.localizedDescription ?? "")")
                return
            }
            
            let recentTemp = result.mostRecentQuantity()
            
            let metricOrImperial = UnitLength(forLocale: .current)
            let unit = metricOrImperial == .feet ? HKUnit.degreeFahrenheit() : HKUnit.degreeCelsius()
            
            let bodyTemp = recentTemp?.doubleValue(for: unit)
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
    
    func loadBodyTempTwoWeeks() {
        bodyTempByDayLoading = true
        
        let quantityType = HKQuantityType(.appleSleepingWristTemperature)
        
        let calendar = Calendar.current
        
        // Begin looking for body temp 6 hours before midnight of 14 days ago
        let start = calendar.startOfDay(for: .now).addingTimeInterval(-1036800)
        
        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: nil,
            options: .mostRecent,
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
                if let quantity = statistics.mostRecentQuantity() {
                    let bodyTemp = quantity.doubleValue(for: unit)
                    let date = statistics.endDate
                    
                    bodyTempByDayTemp[date] = bodyTemp
                }
            }
            
            DispatchQueue.main.async {
                self.bodyTempByDay = bodyTempByDayTemp
                
                var hasBodyTempToday = false
                for (date, _) in bodyTempByDayTemp {
                    if date.isToday() {
                        hasBodyTempToday = true
                        break
                    }
                }
                
                self.hasBodyTempToday = hasBodyTempToday ? true : false
                
                self.bodyTempByDayLoading = false
            }
        }
        
        healthStore.execute(query)
    }
}
