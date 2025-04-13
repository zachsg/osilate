//
//  SessionPagingView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/12/25.
//

import SwiftUI
import WatchKit

struct SessionPagingView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @Environment(WorkoutManager.self) private var workoutManager
    
    @State private var selection: Tab = .metrics
    
    enum Tab {
        case controls, metrics, nowPlaying
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tabItem {
                Text("Controls")
            }
            .tag(Tab.controls)
            
            MetricsView().tabItem {
                Text("Metrics")
            }
            .tag(Tab.metrics)
            
            NowPlayingView().tabItem {
                Text("Now Playing")
            }
            .tag(Tab.nowPlaying)
        }
        .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
        .navigationBarBackButtonHidden()
        .toolbar(selection == .nowPlaying ? .hidden : .visible, for: .navigationBar)
        .onChange(of: workoutManager.running) { oldValue, newValue in
            displayMetrics()
        }
        .tabViewStyle(
            .page(indexDisplayMode: isLuminanceReduced ? .never : .automatic)
        )
        .onChange(of: isLuminanceReduced) { oldValue, newValue in
            displayMetrics()
        }
    }
    
    private func displayMetrics() {
        withAnimation {
            selection = .metrics
        }
    }
}

#Preview {
    SessionPagingView()
        .environment(WorkoutManager())
}
