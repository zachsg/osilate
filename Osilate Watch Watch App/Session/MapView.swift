//
//  MapView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/13/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    @State private var shouldRenderMap = false
    @State private var userZoomDistance: Double = 300 {
        didSet {
            print("Zoom is now: $\(userZoomDistance)")
        }
    }
    
    var body: some View {
        ZStack {
            if shouldRenderMap {
                MapContent(userZoomDistance: $userZoomDistance)
            } else {
                ProgressView("Loading Map...")
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        // Force refresh
                        shouldRenderMap = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            shouldRenderMap = true
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .padding(4)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            // Delay map rendering to give the view time to initialize
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                shouldRenderMap = true
            }
        }
    }
    
    struct MapContent: View {
        @Environment(WorkoutManager.self) private var workoutManager
        
        @Binding var userZoomDistance: Double
        
        @State private var position: MapCameraPosition = .automatic
        @State private var isUserInteracting = false
        
        var body: some View {
            Map(position: $position, interactionModes: .all) {
                UserAnnotation()
                
                if workoutManager.locations.count > 1 {
                    MapPolyline(coordinates: workoutManager.locations.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(.standard(elevation: .realistic, pointsOfInterest: []))
            .mapControls {
                MapCompass()
                    .mapControlVisibility(.visible)
            }
            .overlay(alignment: .center) {
                if workoutManager.locations.isEmpty {
                    Text("No location data available")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        
                        Button {
                            recenterMap()
                        } label: {
                            Image(systemName: "location.fill")
                                .padding(4)
                                .background(.regularMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .onAppear {
                // Start with map locked to user location and direction
                setInitialPosition()
            }
            .onChange(of: workoutManager.locations) { _, newLocations in
                // When location updates, follow the user if not manually panned
                if !isUserInteracting && newLocations.count >= 2 {
                    followUserLocationAndDirection(newLocations)
                }
            }
            // Using gesture to detect user interaction with the map
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in
                        isUserInteracting = true
                    }
            )
            .digitalCrownRotation($userZoomDistance, from: 50, through: 1000, by: 50, sensitivity: .low, isContinuous: false)
        }
        
        private func setInitialPosition() {
            if workoutManager.locations.count >= 2 {
                followUserLocationAndDirection(workoutManager.locations)
            } else if let location = workoutManager.locations.last {
                withAnimation {
                    position = .camera(MapCamera(
                        centerCoordinate: location.coordinate,
                        distance: userZoomDistance,
                        heading: 0,
                        pitch: 0
                    ))
                }
            } else {
                position = .automatic
            }
        }
        
        private func calculateHeading(from locations: [CLLocation]) -> CLLocationDirection {
            guard locations.count >= 2 else { return 0 }
            
            // Get the last two locations to calculate direction
            let lastLocation = locations.last!
            
            // Find a previous location that's far enough away to calculate a meaningful heading
            var previousIndex = locations.count - 2
            var previousLocation = locations[previousIndex]
            let minimumDistance: CLLocationDistance = 5 // 5 meters minimum for reliable heading
            
            // Try to find a previous location that's far enough away
            while previousIndex > 0 && lastLocation.distance(from: previousLocation) < minimumDistance {
                previousIndex -= 1
                previousLocation = locations[previousIndex]
            }
            
            // If we couldn't find a location far enough away, use the most recent previous location
            if lastLocation.distance(from: previousLocation) < minimumDistance {
                previousLocation = locations[locations.count - 2]
            }
            
            // Calculate the heading based on the change in coordinates
            let deltaLat = lastLocation.coordinate.latitude - previousLocation.coordinate.latitude
            let deltaLong = lastLocation.coordinate.longitude - previousLocation.coordinate.longitude
            
            // Convert to heading in degrees (0° is North, 90° is East)
            let heading = atan2(deltaLong, deltaLat) * 180 / .pi
            
            // Normalize to 0-360 range
            return heading >= 0 ? heading : heading + 360
        }
        
        private func followUserLocationAndDirection(_ locations: [CLLocation]) {
            guard let lastLocation = locations.last else { return }
            
            // Calculate the heading from the recent locations
            let heading = calculateHeading(from: locations)
            
            // Update the map camera position with the current location and heading
            withAnimation {
                position = .camera(MapCamera(
                    centerCoordinate: lastLocation.coordinate,
                    distance: userZoomDistance,
                    heading: heading,
                    pitch: 0
                ))
            }
        }
        
        private func recenterMap() {
            isUserInteracting = false // Re-enable auto-follow
            
            if workoutManager.locations.count >= 2 {
                followUserLocationAndDirection(workoutManager.locations)
            } else if let location = workoutManager.locations.last {
                withAnimation {
                    position = .camera(MapCamera(
                        centerCoordinate: location.coordinate,
                        distance: userZoomDistance,
                        heading: 0,
                        pitch: 0
                    ))
                }
            }
        }
    }
}

#Preview {
    let workoutManager = WorkoutManager()
    // Add some sample locations for preview
    let coordinates = [
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4180),
        CLLocationCoordinate2D(latitude: 37.7748, longitude: -122.4170)
    ]
    workoutManager.locations = coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
    
    return MapView()
        .environment(workoutManager)
}
