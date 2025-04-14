//
//  ElevationView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/14/25.
//

import SwiftUI

struct ElevationView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Label {
                Text(
                    Measurement(
                        value: workoutManager.elevationGain,
                        unit: UnitLength.meters
                    )
                    .formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road,
                        )
                    )
                )
            } icon: {
                Image(systemName: "arrow.up.circle.fill")
            }
        }
    }
}

#Preview {
    ElevationView()
        .environment(WorkoutManager())
}
