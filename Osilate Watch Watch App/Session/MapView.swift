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
    
    var body: some View {
        ZStack {
            if shouldRenderMap {
                // Simple map implementation
                MapContent()
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Loading placeholder
                ProgressView("Loading Map...")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // Force refresh
                    shouldRenderMap = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        shouldRenderMap = true
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .padding(2)
                        .background(.regularMaterial)
                        .clipShape(Circle())
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
        // Define a constant for the display radius (200 meters)
        private let displayRadiusMeters: Double = 200
        // State to manage the map position
        @State private var position: MapCameraPosition = .automatic
        // Track whether we should follow the user's location
        @State private var isFollowingUser: Bool = true
        
        var body: some View {
            Map(position: $position) {
                // Show current location marker
                if let currentLocation = workoutManager.locations.last {
                    Annotation("", coordinate: currentLocation.coordinate) {
                        Circle()
                            .fill(.blue)
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Show route polyline
                if workoutManager.locations.count > 1 {
                    MapPolyline(coordinates: workoutManager.locations.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 3)
                }
            }
            .mapStyle(.standard(pointsOfInterest: []))
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    withAnimation {
                        centerOnUserWithDefaultZoom()
                        isFollowingUser = true
                    }
                }) {
                    Image(systemName: isFollowingUser ? "location.fill.circle.fill" : "location.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .background(Circle().fill(.white).frame(width: 36, height: 36))
                        .shadow(radius: 2)
                }
                .padding([.trailing, .bottom], 10)
            }
            .overlay(alignment: .center) {
                if workoutManager.locations.isEmpty {
                    Text("No location data available")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
            }
            .onAppear {
                // Set initial position to be centered on user with 200m radius
                centerOnUserWithDefaultZoom()
                isFollowingUser = true
            }
            .onChange(of: workoutManager.locations) { oldValue, newValue in
                // Only auto-recenter if we're in following mode
                if isFollowingUser, let lastNewLocation = newValue.last, let lastOldLocation = oldValue.last, !newValue.isEmpty {
                    // Compare the latitude and longitude separately since CLLocationCoordinate2D doesn't conform to Equatable
                    if lastNewLocation.coordinate.latitude != lastOldLocation.coordinate.latitude ||
                       lastNewLocation.coordinate.longitude != lastOldLocation.coordinate.longitude {
                        centerOnUserWithDefaultZoom()
                    }
                }
            }
            // Detect when the user interacts with the map using a DragGesture which is available on WatchOS
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { _ in
                        // Disable following as soon as the user starts dragging
                        if isFollowingUser {
                            isFollowingUser = false
                        }
                    }
            )
            // Add a tap gesture recognizer to detect when position changes via Digital Crown or other means
            .onChange(of: position) { oldPosition, newPosition in
                // Assuming the position change is due to user interaction if we're not performing a programmatic update
                if isFollowingUser {
                    // Check if this is a user-initiated change or our own programmatic update
                    // We can use a simple heuristic - if we're in following mode and the position changed,
                    // it might be due to the Digital Crown since we'd only update while following
                    // for location changes which we handle separately
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Short delay to allow our own programmatic updates to complete
                        // If position changed and we didn't just center it programmatically,
                        // assume it was user interaction
                        isFollowingUser = false
                    }
                }
            }
        }
        
        private func centerOnUserWithDefaultZoom() {
            if let currentLocation = workoutManager.locations.last {
                position = .camera(
                    MapCamera(
                        centerCoordinate: currentLocation.coordinate,
                        distance: displayRadiusMeters * 2, // Distance is diameter, so multiply by 2 for radius effect
                        heading: 0,
                        pitch: 0
                    )
                )
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
