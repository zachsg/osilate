//
//  WorkoutMap.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/16/25.
//

import HealthKit
import MapKit
import SwiftUI

struct WorkoutMap: View {
    @Environment(HealthController.self) private var healthController
    
    let workout: HKWorkout
    @Binding var sheetIsShowing: Bool
    
    @State private var routeLocations: [CLLocation] = []
    @State private var isLoadingRoute = true
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                WorkoutCardCompressed(workout: workout)

                ZStack {
                    
                    Map {
                        if routeLocations.count > 1 {
                            MapPolyline(coordinates: routeLocations.map { $0.coordinate })
                                .stroke(.blue, lineWidth: 4)
                        }
                        
                        if let firstLocation = routeLocations.first {
                            Marker("Start", coordinate: firstLocation.coordinate)
                                .tint(.green)
                        }
                        
                        if let lastLocation = routeLocations.last, routeLocations.count > 1 {
                            Marker("End", coordinate: lastLocation.coordinate)
                                .tint(.red)
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic, pointsOfInterest: []))
                    
                    if isLoadingRoute {
                        ProgressView("Loading route...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    } else if routeLocations.isEmpty {
                        Text("No route data available")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button {
                            sheetIsShowing.toggle()
                        } label: {
                            Label {
                                Text(closeLabel)
                            } icon: {
                                Image(systemName: cancelSystemImage)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadWorkoutRoute()
        }
    }
    
    private func loadWorkoutRoute() {
        isLoadingRoute = true
        
        // Access the HealthKit store
        let healthStore = HKHealthStore()
        
        // Create the route query
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKSampleQuery(sampleType: routeType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard error == nil else {
                print("Error querying routes: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    isLoadingRoute = false
                }
                return
            }
            
            guard let routes = samples as? [HKWorkoutRoute], let route = routes.first else {
                print("No routes found for this workout")
                DispatchQueue.main.async {
                    isLoadingRoute = false
                }
                return
            }
            
            // Now that we have the route, let's get the location data
            let routeQuery = HKWorkoutRouteQuery(route: route) { query, locations, done, error in
                guard error == nil else {
                    print("Error querying route data: \(error!.localizedDescription)")
                    return
                }
                
                if let locations = locations {
                    DispatchQueue.main.async {
                        // Add new locations to our array
                        routeLocations.append(contentsOf: locations)
                        
                        if done {
                            isLoadingRoute = false
                            calculateRegion()
                        }
                    }
                }
            }
            
            healthStore.execute(routeQuery)
        }
        
        healthStore.execute(query)
    }
    
    private func calculateRegion() {
        guard !routeLocations.isEmpty else { return }
        
        // Find the min/max coordinates to determine the bounding box
        var minLat = routeLocations[0].coordinate.latitude
        var maxLat = routeLocations[0].coordinate.latitude
        var minLon = routeLocations[0].coordinate.longitude
        var maxLon = routeLocations[0].coordinate.longitude
        
        for location in routeLocations {
            minLat = min(minLat, location.coordinate.latitude)
            maxLat = max(maxLat, location.coordinate.latitude)
            minLon = min(minLon, location.coordinate.longitude)
            maxLon = max(maxLon, location.coordinate.longitude)
        }
        
        // Calculate center
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        // Calculate span with some padding (20%)
        let latDelta = (maxLat - minLat) * 1.2
        let lonDelta = (maxLon - minLon) * 1.2
        
        // Ensure minimum span for visibility
        let finalLatDelta = max(latDelta, 0.005)
        let finalLonDelta = max(lonDelta, 0.005)
        
        // Update the region
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: finalLatDelta, longitudeDelta: finalLonDelta)
        )
    }
}

#Preview {
    WorkoutMap(workout: MockWorkout().createMockWorkout(), sheetIsShowing: .constant(true))
        .environment(HealthController())
}
