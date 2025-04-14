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
    @State private var region = MKCoordinateRegion()
    @State private var mapRect: MKMapRect?
    
    var body: some View {
        Map(position: .constant(.rect(mapRect ?? MKMapRect())),
            interactionModes: .all) {
            UserAnnotation()
            
            if !workoutManager.locations.isEmpty {
                MapPolyline(coordinates: workoutManager.locations.map { $0.coordinate })
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .onAppear {
            centerMapOnUserLocation()
        }
        .onChange(of: workoutManager.locations) { oldLocations, newLocations in
            if !newLocations.isEmpty {
                updateMapWithLocations(newLocations)
            }
        }
    }
    
    private func centerMapOnUserLocation() {
        if let userLocation = workoutManager.locations.last {
            // Create a region centered on the user's current location
            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            let point = MKMapPoint(userLocation.coordinate)
            let size = MKMapSize(width: 1000, height: 1000)
            mapRect = MKMapRect(origin: point, size: size)
        }
    }
    
    private func updateMapWithLocations(_ locations: [CLLocation]) {
        // Create a map rect that contains all locations
        if locations.count > 1 {
            var rect = MKMapRect.null
            
            for location in locations {
                let point = MKMapPoint(location.coordinate)
                let pointRect = MKMapRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
                rect = rect.union(pointRect)
            }
            
            // Set the map to show the entire path with some padding
            mapRect = rect.insetBy(dx: -rect.width * 0.1, dy: -rect.height * 0.1)
        } else if let location = locations.last {
            // If there's only one location, center on it
            centerMapOnUserLocation()
        }
    }
}

#Preview {
    MapView()
        .environment(WorkoutManager())
}
