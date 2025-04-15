//
//  WorkoutManager.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/12/25.
//

import CoreLocation
import Foundation
import HealthKit
import Observation

@Observable
class WorkoutManager: NSObject {
    override
    init() {
        super.init()
        setupLocationManager()
    }
    
    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }
    
    var showingSummaryView: Bool = false {
        didSet {
            // Sheet dismissed
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var isOutdoors = false
    
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = isOutdoors ? .outdoor : .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print("error...")
            // Handle any exceptions.
            return
        }
        
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
        
        session?.delegate = self
        builder?.delegate = self
        
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { success, error in
            // The workout has started.
            print("Session started and data collection in progress.")
        }
        
        if isOutdoors {
            let authStatus = locationManager.authorizationStatus
            if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
                print("Started updating location for outdoor workout")
            } else {
                print("Cannot start location updates - authorization not granted")
            }
        }
        
        Task {
            do {
                try await session?.startMirroringToCompanionDevice()
            } catch {
                
            }
        }
    }
    
    func requestAuthorization() {
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKSeriesType.workoutRoute()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }
    
    // MARK: - State Control
    var running = false
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
    }
    
    func endWorkout() {
        if isOutdoors {
            locationManager.stopUpdatingLocation()
        }
        
        session?.end()
        showingSummaryView = true
        
        Task {
            do {
                try await session?.stopMirroringToCompanionDevice()
            } catch {
                print("Error stopping mirroring: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Workout Metrics
    var averageHeartRate: Double = 0
    var heartRate: Double = 0
    var activeEnergy: Double = 0
    var distance: Double = 0
    var elevationStart: Double = 0
    var elevationGain: Double = 0
    var elevationLost: Double = 0
    var relativeElevationChange: Double = 0
    var lastElevation: Double?
    var workout: HKWorkout?
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }
    
    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
        locations = []
        elevationStart = 0
        elevationGain = 0
        elevationLost = 0
        relativeElevationChange = 0
        lastElevation = nil
    }
    
    // MARK: - Location
    let locationManager = CLLocationManager()
    var locations: [CLLocation] = []
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }
        
        if toState == .ended {
            builder?.endCollection(withEnd: date) { success, error in
                self.builder?.finishWorkout { workout, error in
                    guard let workout, error == nil else {
                        print("Error finishing workout: \(error?.localizedDescription ?? "Unknown")")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.workout = workout
                        self.showingSummaryView = true
                        
                        if self.isOutdoors && !self.locations.isEmpty {
                            self.saveWorkoutRoute(for: workout)
                        }
                    }
                }
            }
        }
    }
    
    private func saveWorkoutRoute(for workout: HKWorkout) {
        guard !locations.isEmpty else { return }
        
        let routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
        
        // Insert location data
        routeBuilder.insertRouteData(locations) { success, error in
            if !success {
                print("Failed to insert route data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Finish and save route
            let metadata: [String: Any] = [HKMetadataKeyWasUserEntered: false]
            routeBuilder.finishRoute(with: workout, metadata: metadata) { route, error in
                if let error = error {
                    print("Error saving route: \(error.localizedDescription)")
                } else {
                    print("Successfully saved workout route")
                }
            }
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
    
    func workoutBuilderDidCollectEvent(_ event: HKWorkoutEvent) {
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            updateForStatistics(statistics)
        }
    }
}

// MARK: - CoreLocation
extension WorkoutManager: CLLocationManagerDelegate {
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 2
        locationManager.allowsBackgroundLocationUpdates = true
        
        // Force the permission dialog to appear immediately
        DispatchQueue.main.async {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        // Check current status and log it
        let _ = locationManager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        guard let location = newLocations.last else { return }
        
        // Filter out invalid or old locations
        if location.horizontalAccuracy < 0 || location.horizontalAccuracy > 30 || location.timestamp.timeIntervalSinceNow < -30 {
            print("Skipping low quality location: accuracy \(location.horizontalAccuracy)m")
            return
        }
        
        locations.append(location)
        
        if elevationStart == 0 {
            elevationStart = location.altitude
        }
        
        // Calculate elevation gain
        if let lastLocation = locations.dropLast().last {
            let elevationChange = location.altitude - lastLocation.altitude
            if elevationChange > 0 && elevationChange < 200 {
                elevationGain += elevationChange
            } else if elevationChange < 0 && elevationChange > -200 {
                elevationLost -= abs(elevationChange)
            }
            
            relativeElevationChange = elevationStart - location.altitude
            
            lastElevation = lastLocation.altitude
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // If a workout is already in progress and outdoors, start updating
            if session != nil && isOutdoors {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            print("Location authorization denied")
        case .notDetermined:
            print("Location authorization not determined yet")
        @unknown default:
            break
        }
    }
}
