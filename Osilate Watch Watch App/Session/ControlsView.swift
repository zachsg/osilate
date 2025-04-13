//
//  ControlsView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/12/25.
//

import SwiftUI

struct ControlsView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    var body: some View {
        HStack {
            VStack {
                Button {
                    workoutManager.endWorkout()
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(.red)
                .font(.title2)
                
                Text("End")
            }
            
            VStack {
                Button {
                    workoutManager.togglePause()
                } label: {
                    Image(systemName: workoutManager.running ? "pause" : "play")
                }
                .tint(.yellow)
                .font(.title2)
                
                Text(workoutManager.running ? "Pause" : "Resume")
            }
        }
    }
}

#Preview {
    ControlsView()
        .environment(WorkoutManager())
}
