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
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        // Use a simpler Map implementation first
        ZStack {
            Map {
                // Only show user location marker if we have at least one location
                if let currentLocation = workoutManager.locations.last {
                    // Custom marker for current location
                    Annotation("", coordinate: currentLocation.coordinate) {
                        Circle()
                            .fill(.blue)
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 16, height: 16)
                    }
                }
                
                // Display route using polyline if we have multiple locations
                if workoutManager.locations.count > 1 {
                    MapPolyline(coordinates: workoutManager.locations.map { $0.coordinate })
                        .stroke(.blue, lineWidth: 3)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    updateMapPosition()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .padding(4)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .onAppear {
            updateMapPosition()
        }
        .onChange(of: workoutManager.locations) { _, _ in
            // Only update position when there are significant changes
            // to reduce the number of updates
            if workoutManager.locations.count % 5 == 0 {
                updateMapPosition()
            }
        }
    }
    
    private func updateMapPosition() {
        // If we have at least one location, update the camera
        if !workoutManager.locations.isEmpty {
            // Just center on the most recent location with a reasonable zoom level
            // This is simpler and less likely to cause rendering issues
            if let currentLocation = workoutManager.locations.last {
                cameraPosition = .region(MKCoordinateRegion(
                    center: currentLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))
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
