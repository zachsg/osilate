//
//  WorkoutManager.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/12/25.
//

import CoreLocation
import CoreMotion
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
            
            Task {
                try await startWorkout(workoutType: selectedWorkout)
            }
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
    
    func startWorkout(workoutType: HKWorkoutActivityType) async throws {
        if isOutdoors {
            let authStatus = locationManager.authorizationStatus
            if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
                print("Started updating location for outdoor workout")
            } else {
                print("Cannot start location updates - authorization not granted")
            }
            
            startAltimeter()
        }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = isOutdoors ? .outdoor : .indoor
        
        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        
        try await session?.startMirroringToCompanionDevice()
        
        let startDate = Date()
        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)
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
            stopAltimeter()
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
    var heartRateSamples: [(timestamp: Date, value: Double)] = []
    var timeInZones: [OZone: TimeInterval] = [.zero: 0, .one: 0, .two: 0, .three: 0, .four: 0, .five: 0]
    var averageHeartRate: Double = 0
    var heartRate: Double = 0
    var activeEnergy: Double = 0
    var distance: Double = 0
    private var initialElevationReadings: [Double] = []
    private let requiredInitialReadings = 3  // Number of readings to collect before setting elevationStart
    var elevationStart: Double = -1
    var elevationGain: Double = 0
    var elevationLost: Double = 0
    private var lastRelativeAltitude: Double = 0
    var workout: HKWorkout?
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let newHeartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                
                // If we have a valid heart rate reading, store it with timestamp
                if newHeartRate > 0 {
                    self.heartRate = newHeartRate
                    self.heartRateSamples.append((timestamp: Date(), value: newHeartRate))
                    self.updateTimeInZones()
                }
                
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
    
    func sendData(_ data: Data) async {
        do {
            try await session?.sendToRemoteWorkoutSession(data: data)
        } catch {
            print("Error sending data to companion: \(error.localizedDescription)")
        }
    }
    
    private func updateTimeInZones() {
        guard heartRateSamples.count > 1 else { return }
        
        // Reset timeInZones
        timeInZones = [.zero: 0, .one: 0, .two: 0, .three: 0, .four: 0, .five: 0]
        
        // Calculate time spent in each zone
        for i in 1..<heartRateSamples.count {
            let prevSample = heartRateSamples[i-1]
            let currentSample = heartRateSamples[i]
            
            // Calculate time difference between samples
            let timeInterval = currentSample.timestamp.timeIntervalSince(prevSample.timestamp)
            
            // Determine zone for the heart rate value
            let zone = prevSample.value.zone()
            
            // Add the time to the appropriate zone
            if let currentTime = timeInZones[zone] {
                timeInZones[zone] = currentTime + timeInterval
            }
        }
    }
    
    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        activeEnergy = 0
        heartRateSamples = []
        timeInZones = [.zero: 0, .one: 0, .two: 0, .three: 0, .four: 0, .five: 0]
        averageHeartRate = 0
        heartRate = 0
        distance = 0
        locations = []
        initialElevationReadings = []
        elevationStart = -1
        elevationGain = 0
        elevationLost = 0
        isOutdoors = false
    }
    
    // MARK: - Location
    let locationManager = CLLocationManager()
    var locations: [CLLocation] = []
    private let altimeter = CMAltimeter()
    private var isAltimeterActive = false
    private let maxPlausibleRawDelta: Double = 5.0 // Max plausible raw change between consecutive readings (meters)
    private let movingAverageWindowSize: Int = 3 // Number of readings to average (Experiment: 3-5)
    private var altitudeBuffer: [Double] = []   // Stores recent relative altitudes
    private var previousSmoothedAltitude: Double? = nil // Stores the average from the *last* calculation

    // Threshold for the *smoothed* delta (can likely be smaller now)
    let smoothedDeltaThreshold: Double = 0.3
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
        Task { @MainActor in
            var allStatistics: [HKStatistics] = []
            for type in collectedTypes {
                guard let quantityType = type as? HKQuantityType else { return }
                
                let statistics = workoutBuilder.statistics(for: quantityType)
                if let statistics {
                    updateForStatistics(statistics)
                    allStatistics.append(statistics)
                }
            }
            
            let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: allStatistics, requiringSecureCoding: true)
            guard let archivedData = archivedData, !archivedData.isEmpty else {
                return
            }
            
            await sendData(archivedData)
            
            let elapsedTimeInterval = session?.associatedWorkoutBuilder().elapsedTime(at: Date()) ?? 0
            let elapsedTime = WorkoutElapsedTime(timeInterval: elapsedTimeInterval, date: Date())
            if let elapsedTimeData = try? JSONEncoder().encode(elapsedTime) {
                await sendData(elapsedTimeData)
            }
            
            if let locationsData = try? encodeLocations(locations) {
                await sendData(locationsData)
            }
        }
    }
}

struct WorkoutElapsedTime: Codable {
    var timeInterval: TimeInterval
    var date: Date
}

// MARK: - CoreLocation
extension WorkoutManager: CLLocationManagerDelegate {
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
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
        
        // Collect initial elevation readings
        if elevationStart == -1 {
            // Only collect readings when horizontal accuracy is good
            if location.horizontalAccuracy <= 10 && location.verticalAccuracy <= 10 {
                initialElevationReadings.append(location.altitude)
                print("Initial elevation reading: \(location.altitude)m (accuracy: \(location.verticalAccuracy)m)")
                
                // Once we have enough readings, set the elevation start to the median value
                if initialElevationReadings.count >= requiredInitialReadings {
                    // Sort readings and take the middle one (median)
                    let sortedReadings = initialElevationReadings.sorted()
                    let medianIndex = sortedReadings.count / 2
                    elevationStart = sortedReadings[medianIndex]
                    print("Set initial elevation to \(elevationStart)m (median of \(initialElevationReadings.count) readings)")
                }
            }
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
    
    func startAltimeter() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            print("Altimeter not available on this device.")
            return
        }
        
        // Reset state
        isAltimeterActive = true
        lastRelativeAltitude = 0 // Still useful for the raw spike check
        elevationGain = 0
        elevationLost = 0
        altitudeBuffer.removeAll()
        previousSmoothedAltitude = nil

        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, self.isAltimeterActive else { return }

            let currentRawAltitude = data.relativeAltitude.doubleValue
            let rawDelta = currentRawAltitude - self.lastRelativeAltitude // For spike check

            // --- 1. Raw Spike Check ---
            // Still useful to discard truly massive instant jumps before they enter the average
            guard abs(rawDelta) < self.maxPlausibleRawDelta else {
                print("Discarding implausible raw delta: \(rawDelta)m")
                // Don't update lastRelativeAltitude yet, wait for a less spikey reading
                return
            }
            // Update lastRelativeAltitude *after* raw spike check passes
            self.lastRelativeAltitude = currentRawAltitude
            // --- End Raw Spike Check ---


            // --- 2. Moving Average Calculation ---
            // Add current reading to buffer
            self.altitudeBuffer.append(currentRawAltitude)

            // Keep buffer size limited
            if self.altitudeBuffer.count > self.movingAverageWindowSize {
                self.altitudeBuffer.removeFirst()
            }

            // Only proceed if buffer is full enough for a meaningful average
            guard self.altitudeBuffer.count == self.movingAverageWindowSize else {
                // Buffer not full yet, wait for more data
                // Optional: Set initial previousSmoothedAltitude once buffer is full for the first time
                if self.altitudeBuffer.count == self.movingAverageWindowSize && self.previousSmoothedAltitude == nil {
                     self.previousSmoothedAltitude = self.altitudeBuffer.reduce(0, +) / Double(self.movingAverageWindowSize)
                }
                return
            }

            // Calculate current smoothed altitude (average)
            let currentSmoothedAltitude = self.altitudeBuffer.reduce(0, +) / Double(self.movingAverageWindowSize)

            // Ensure we have a previous average to compare against
            guard let prevSmoothedAlt = self.previousSmoothedAltitude else {
                 // This should ideally only happen once after the buffer fills
                 self.previousSmoothedAltitude = currentSmoothedAltitude
                 return
            }

            let smoothedDelta = currentSmoothedAltitude - prevSmoothedAlt
            let absSmoothedDelta = abs(smoothedDelta)
            // --- End Moving Average Calculation ---


            // --- 3. Apply Logic to Smoothed Delta ---
            if absSmoothedDelta > self.smoothedDeltaThreshold {
                 print("Smoothed Delta (\(String(format: "%.2f", smoothedDelta))m) exceeds threshold (\(self.smoothedDeltaThreshold)m).") // Debugging
                if smoothedDelta > 0 {
                    // Accumulate the smoothed change, NOT the raw delta
                    self.elevationGain += smoothedDelta
                     print("  Adding Smoothed Gain: \(String(format: "%.2f", smoothedDelta))m -> Total Gain: \(String(format: "%.2f", self.elevationGain))m")
                } else {
                    self.elevationLost += -smoothedDelta // Add absolute value
                     print("  Adding Smoothed Loss: \(String(format: "%.2f", -smoothedDelta))m -> Total Loss: \(String(format: "%.2f", self.elevationLost))m")
                }
            } else {
                 // Smoothed delta is too small, likely noise that the average dampened.
                 // print("Smoothed Delta (\(String(format: "%.2f", smoothedDelta))m) is below threshold.") // Debugging
            }
            // --- End Apply Logic ---


            // --- 4. Update Previous Smoothed Altitude ---
            // Update for the *next* iteration's comparison
            self.previousSmoothedAltitude = currentSmoothedAltitude
            // --- End Update ---
        }
    }

    func stopAltimeter() {
        isAltimeterActive = false
        altimeter.stopRelativeAltitudeUpdates()
    }
}
