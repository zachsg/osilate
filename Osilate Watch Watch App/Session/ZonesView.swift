//
//  ZonesView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/14/25.
//

import SwiftUI

struct HeartPulse: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    var speed: Double {
        let speed = workoutManager.heartRate / 4
        return speed > 1 ? speed : 1
    }
    
    var body: some View {
        HStack {
            Image(systemName: "heart.fill")
                .symbolEffect(.breathe, options: .speed(speed))

            Text(Int(workoutManager.heartRate), format: .number)
        }
        .font(.caption2.bold().monospacedDigit())
        .padding(.trailing, 4)
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
                workoutManager.heartRate.zoneColor().opacity(0.3)
                
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundStyle(OZone.zero.color().opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.zero), height: 26)
                            
                            Label {
                                HStack {
                                    Text(formatTimeInterval(workoutManager.timeInZones[.zero] ?? 0))
                                    Spacer()
                                    if zone == .zero {
                                        HeartPulse()
                                    }
                                }
                            } icon: {
                                Image(systemName: "0.circle")
                            }
                            .padding(.leading, 2)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundStyle(OZone.one.color().opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.one), height: 26)
                            
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
                                .foregroundStyle(OZone.two.color().opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.two), height: 26)
                            
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
                                .foregroundStyle(OZone.three.color().opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.three), height: 26)
                            
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
                                .foregroundStyle(OZone.four.color().opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.four), height: 26)
                            
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
                                .foregroundStyle(OZone.five.color().opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.five), height: 26)
                            
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
                    .padding(.top, 50)
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
