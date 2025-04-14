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
                        .padding(4)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
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
        @State private var position: MapCameraPosition = .automatic
        @State private var isUserInteracting = false
        
        var body: some View {
            Map(position: $position, interactionModes: .all) {
                // Show current location marker
                if let currentLocation = workoutManager.locations.last {
//                    Annotation("", coordinate: currentLocation.coordinate) {
//                        Circle()
//                            .fill(.blue)
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 16, height: 16)
//                    }
                    
                    UserAnnotation()
                }
                
                // Show route polyline
                if workoutManager.locations.count > 1 {
                    MapPolyline(coordinates: workoutManager.locations.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 3)
                }
            }
            .mapStyle(.standard(pointsOfInterest: []))
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
                        
                        Button(action: {
                            recenterMap()
                        }) {
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
                // Start with map locked to user location
                setInitialPosition()
            }
            .onChange(of: workoutManager.locations) { _, newValue in
                // When location updates, follow the user if not manually panned
                if !isUserInteracting && !newValue.isEmpty {
                    followUserLocation(newValue.last!)
                }
            }
            // Using gesture to detect user interaction with the map
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { _ in
                        isUserInteracting = true
                    }
            )
        }
        
        private func setInitialPosition() {
            if let location = workoutManager.locations.last {
                position = .camera(MapCamera(
                    centerCoordinate: location.coordinate,
                    distance: 300,
                    heading: 0,
                    pitch: 0
                ))
            } else {
                position = .automatic
            }
        }
        
        private func followUserLocation(_ location: CLLocation) {
            withAnimation {
                position = .camera(MapCamera(
                    centerCoordinate: location.coordinate,
                    distance: 300,
                    heading: 0,
                    pitch: 0
                ))
            }
        }
        
        private func recenterMap() {
            if let location = workoutManager.locations.last {
                isUserInteracting = false // Re-enable auto-follow
                followUserLocation(location)
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
