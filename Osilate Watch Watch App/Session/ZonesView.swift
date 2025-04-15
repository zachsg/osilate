//
//  ZonesView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/14/25.
//

import SwiftUI

struct ZonesView: View {
    @Environment(WorkoutManager.self) private var workoutManager

    var body: some View {
        ZStack {
            workoutManager.heartRate.zoneColor().opacity(0.2)
            
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.green.opacity(0.7))
                            .frame(width: geometry.size.width * zonePercentage(.one), height: 34)
                        
                        Label {
                            Text(formatTimeInterval(workoutManager.timeInZones[.one] ?? 0))
                        } icon: {
                            Image(systemName: "1.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.yellow.opacity(0.7))
                            .frame(width: geometry.size.width * zonePercentage(.two), height: 34)
                        
                        Label {
                            Text(formatTimeInterval(workoutManager.timeInZones[.two] ?? 0))
                        } icon: {
                            Image(systemName: "2.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.orange.opacity(0.7))
                            .frame(width: geometry.size.width * zonePercentage(.three), height: 34)
                        
                        Label {
                            Text(formatTimeInterval(workoutManager.timeInZones[.three] ?? 0))
                        } icon: {
                            Image(systemName: "3.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.red.opacity(0.7))
                            .frame(width: geometry.size.width * zonePercentage(.four), height: 34)
                        
                        Label {
                            Text(formatTimeInterval(workoutManager.timeInZones[.four] ?? 0))
                        } icon: {
                            Image(systemName: "4.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.purple.opacity(0.7))
                            .frame(width: geometry.size.width * zonePercentage(.five), height: 34)
                        
                        Label {
                            Text(formatTimeInterval(workoutManager.timeInZones[.five] ?? 0))
                        } icon: {
                            Image(systemName: "5.circle")
                        }
                    }
                }
                .font(.title2.monospacedDigit().lowercaseSmallCaps())
                .frame(maxWidth: .infinity, alignment: .leading)
                .scenePadding()
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea()
    }
    
    // Helper function to calculate the percentage width for each zone
    private func zonePercentage(_ zone: OZone) -> Double {
        let totalTime = workoutManager.timeInZones.values.reduce(0, +)
        guard totalTime > 0 else { return 0 }
        
        return (workoutManager.timeInZones[zone] ?? 0) / totalTime
    }
    
    // Format time interval as MM:SS
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ZonesView()
        .environment(WorkoutManager())
}
