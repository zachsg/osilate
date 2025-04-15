//
//  ZonesView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/14/25.
//

import SwiftUI

struct ZoneBorder: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    var zone: OZone
    
    var currentZone: OZone {
        workoutManager.heartRate.zone()
    }
    
    var body: some View {
        if currentZone == zone {
            RoundedRectangle(cornerRadius: 2)
                .stroke(.white, lineWidth: 2)
        }
    }
}

struct HeartPulse: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            Image(systemName: "heart.fill")
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            Text(Int(workoutManager.heartRate), format: .number)
        }
        .font(.caption2.bold())
        .padding(.trailing, 4)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ZonesView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    var zone: OZone {
        workoutManager.heartRate.zone()
    }

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1.0)) { timeline in
            ZStack {
                workoutManager.heartRate.zoneColor().opacity(0.2)
                
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 2) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundStyle(.green.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.one), height: 28)
                                .overlay {
                                    ZoneBorder(zone: .one)
                                }
                            
                            Label {
                                HStack {
                                    Text(formatTimeInterval(workoutManager.timeInZones[.one] ?? 0))
                                    Spacer()
                                    if zone == .one {
                                        HeartPulse()
                                    }
                                }
                            } icon: {
                                Image(systemName: "1.circle")
                            }
                            .padding(.leading, 2)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(.yellow.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.two), height: 28)
                                .overlay {
                                    ZoneBorder(zone: .two)
                                }
                            
                            Label {
                                HStack {
                                    Text(formatTimeInterval(workoutManager.timeInZones[.two] ?? 0))
                                    Spacer()
                                    if zone == .two {
                                        HeartPulse()
                                    }
                                }
                            } icon: {
                                Image(systemName: "2.circle")
                            }
                            .padding(.leading, 2)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(.orange.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.three), height: 28)
                                .overlay {
                                    ZoneBorder(zone: .three)
                                }
                            
                            Label {
                                HStack {
                                    Text(formatTimeInterval(workoutManager.timeInZones[.three] ?? 0))
                                    Spacer()
                                    if zone == .three {
                                        HeartPulse()
                                    }
                                }
                            } icon: {
                                Image(systemName: "3.circle")
                            }
                            .padding(.leading, 2)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(.red.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.four), height: 28)
                                .overlay {
                                    ZoneBorder(zone: .four)
                                }
                            
                            Label {
                                HStack {
                                    Text(formatTimeInterval(workoutManager.timeInZones[.four] ?? 0))
                                    Spacer()
                                    if zone == .four {
                                        HeartPulse()
                                    }
                                }
                            } icon: {
                                Image(systemName: "4.circle")
                            }
                            .padding(.leading, 2)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .foregroundStyle(.purple.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.five), height: 28)
                                .overlay {
                                    ZoneBorder(zone: .five)
                                }
                            
                            Label {
                                HStack {
                                    Text(formatTimeInterval(workoutManager.timeInZones[.five] ?? 0))
                                    Spacer()
                                    if zone == .five {
                                        HeartPulse()
                                    }
                                }
                            } icon: {
                                Image(systemName: "5.circle")
                            }
                            .padding(.leading, 2)
                        }
                    }
                    .font(.title3.monospacedDigit().lowercaseSmallCaps())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scenePadding()
                    .padding(.top, 60)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    // Helper function to calculate the percentage width for each zone
    private func zonePercentage(_ zone: OZone) -> Double {
        let totalTime = workoutManager.timeInZones.values.reduce(0, +)
        guard totalTime > 0 else { return 0 }
        
        return (workoutManager.timeInZones[zone] ?? 0) / totalTime * 0.88
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
