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
    
    @State private var selection: Tab = .primary
    @State private var showingMap = false
    
    enum Tab {
        case controls, primary, nowPlaying
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tabItem {
                Text("Controls")
            }
            .tag(Tab.controls)
            
            PrimaryView().tabItem {
                Text("Primary")
            }
            .tag(Tab.primary)
            
            NowPlayingView().tabItem {
                Text("Now Playing")
            }
            .tag(Tab.nowPlaying)
        }
        .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
//        .navigationTitle(workoutManager.builder?.elapsedTime.secondsAsTime(units: .abbreviated) ?? "")
        .navigationBarBackButtonHidden()
        .toolbar(selection == .nowPlaying ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(systemName: workoutManager.selectedWorkout?.systemName(outdoors: workoutManager.isOutdoors) ?? "")
            }
            
            if workoutManager.isOutdoors {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Map", systemImage: "map") {
                        showingMap = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingMap) {
            MapView()
        }
        .onChange(of: workoutManager.running) { oldValue, newValue in
            displayPrimary()
        }
        .tabViewStyle(
            .page(indexDisplayMode: isLuminanceReduced ? .never : .automatic)
        )
        .onChange(of: isLuminanceReduced) { oldValue, newValue in
            displayPrimary()
        }
    }
    
    private func displayPrimary() {
        withAnimation {
            selection = .primary
        }
    }
}

#Preview {
    SessionPagingView()
        .environment(WorkoutManager())
}
