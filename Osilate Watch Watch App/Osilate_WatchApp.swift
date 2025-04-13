//
//  Osilate_WatchApp.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/11/25.
//

import SwiftUI

@main
struct Osilate_Watch_Watch_AppApp: App {
    @State private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(workoutManager)
        }
    }
}
