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
        Map(position: $cameraPosition) {
            // Only show user location marker if we have at least one location
            if let currentLocation = workoutManager.locations.last {
                // Custom marker for current location
                Marker("Current", coordinate: currentLocation.coordinate)
                    .tint(.blue)
            }
            
            // Display route using polyline
            if workoutManager.locations.count > 1 {
                MapPolyline(coordinates: workoutManager.locations.map { $0.coordinate })
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .mapStyle(.standard)
        .onAppear {
            updateMapPosition()
        }
        .onChange(of: workoutManager.locations) { _, _ in
            updateMapPosition()
        }
    }
    
    private func updateMapPosition() {
        // If we have multiple locations, show the entire route
        if workoutManager.locations.count > 1 {
            let coordinates = workoutManager.locations.map { $0.coordinate }
            cameraPosition = .rect(MKMapRect(coordinates: coordinates).insetBy(dx: -200, dy: -200))
        }
        // If we have only one location, center on it
        else if let currentLocation = workoutManager.locations.last {
            cameraPosition = .region(MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        }
    }
}

// Helper extension to create MKMapRect from an array of coordinates
extension MKMapRect {
    init(coordinates: [CLLocationCoordinate2D]) {
        self = .null
        
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            let rect = MKMapRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2)
            
            if self.isNull {
                self = rect
            } else {
                self = self.union(rect)
            }
        }
    }
}

#Preview {
    MapView()
        .environment(WorkoutManager())
}
