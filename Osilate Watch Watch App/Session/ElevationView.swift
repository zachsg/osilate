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
                        value: workoutManager.lastElevation ?? 0,
                        unit: UnitLength.meters
                    )
                    .formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road
                        )
                    )
                )
            } icon: {
                Image(systemName: "mountain.2.circle.fill")
            }
            
            Label {
                Text(
                    Measurement(
                        value: workoutManager.elevationGain,
                        unit: UnitLength.meters
                    )
                    .formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road
                        )
                    )
                )
            } icon: {
                Image(systemName: "arrow.up.circle.fill")
            }
        }
        .font(.title.monospacedDigit().lowercaseSmallCaps())
        .frame(maxWidth: .infinity, alignment: .leading)
        .scenePadding()
        .padding(.top, 40)
    }
}

#Preview {
    ElevationView()
        .environment(WorkoutManager())
}
