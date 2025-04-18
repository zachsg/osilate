//
//  MapView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/18/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    @Environment(HealthController.self) private var healthController
    
    var body: some View {
        Map {
            UserAnnotation()
            
            if healthController.locations.count > 1 {
                MapPolyline(coordinates: healthController.locations.map { $0.coordinate })
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: []))
        .mapControls {
            MapCompass()
                .mapControlVisibility(.visible)
        }
        .overlay(alignment: .center) {
            if healthController.locations.isEmpty {
                Text("No location data available")
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    MapView()
        .environment(HealthController())
}
