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
        
        var body: some View {
            Map {
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
            .overlay(alignment: .center) {
                if workoutManager.locations.isEmpty {
                    Text("No location data available")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
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
