//
//  PrimaryView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/14/25.
//

import SwiftUI

struct PrimaryView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    @State private var selection: Tab = .metrics
    
    enum Tab {
        case metrics, elevation
    }
    
    var body: some View {
        TabView(selection: $selection) {
            MetricsView().tabItem {
                Text("Metrics")
            }
            .tag(Tab.metrics)
            
            if workoutManager.isOutdoors {
                ElevationView().tabItem {
                    Text("Elevation")
                }.tag(Tab.elevation)
            }
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    PrimaryView()
        .environment(WorkoutManager())
}
