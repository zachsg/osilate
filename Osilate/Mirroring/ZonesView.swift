//
//  ZonesView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/15/25.
//

import SwiftUI

struct HeartPulse: View {
    @Environment(HealthController.self) private var healthController
    
    var speed: Double {
        let speed = healthController.heartRate / 4
        return speed > 1 ? speed : 1
        
    }
    
    var body: some View {
        HStack {
            Image(systemName: "heart.fill")
                .symbolEffect(.breathe, options: .speed(speed))
            
            Text(Int(healthController.heartRate), format: .number)
        }
        .font(.title.bold().monospacedDigit())
        .padding(.trailing)
    }
}

struct ElapsedTime: View {
    var elapsed: TimeInterval
    
    var body: some View {
        Text(format(elapsed))
    }
    
    private func format(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional // e.g., "1:01:05"
        formatter.zeroFormattingBehavior = .pad // Ensures leading zeros, e.g., "01" for 1 minute
        return formatter.string(from: timeInterval) ?? "0:00:00"
    }
}

struct ZonesView: View {
    @Environment(HealthController.self) private var healthController
    
    var zone: OZone {
        healthController.heartRate.zone()
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                healthController.heartRate.zoneColor().opacity(0.3)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Spacer()
                            ElapsedTime(elapsed: healthController.elapsedTimeInterval)
                                .font(.largeTitle.monospacedDigit().bold())
                            Spacer()
                        }
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .foregroundStyle(OZone.zero.color().opacity(0.7))
                                        .frame(width: geometry.size.width * zonePercentage(.zero), height: 48)
                                    
                                    Label {
                                        HStack {
                                            Text(formatTimeInterval(healthController.timeInZones[.zero] ?? 0))
                                            Spacer()
                                            if zone == .zero {
                                                HeartPulse()
                                            }
                                        }
                                    } icon: {
                                        Image(systemName: "0.circle")
                                    }
                                    .padding(.leading, 12)
                                }
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .foregroundStyle(OZone.one.color().opacity(0.7))
                                        .frame(width: geometry.size.width * zonePercentage(.one), height: 48)
                                    
                                    Label {
                                        HStack {
                                            Text(formatTimeInterval(healthController.timeInZones[.one] ?? 0))
                                            Spacer()
                                            if zone == .one {
                                                HeartPulse()
                                            }
                                        }
                                    } icon: {
                                        Image(systemName: "1.circle")
                                    }
                                    .padding(.leading, 12)
                                }
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(OZone.two.color().opacity(0.7))
                                        .frame(width: geometry.size.width * zonePercentage(.two), height: 48)
                                    
                                    Label {
                                        HStack {
                                            Text(formatTimeInterval(healthController.timeInZones[.two] ?? 0))
                                            Spacer()
                                            if zone == .two {
                                                HeartPulse()
                                            }
                                        }
                                    } icon: {
                                        Image(systemName: "2.circle")
                                    }
                                    .padding(.leading, 12)
                                }
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(OZone.three.color().opacity(0.7))
                                        .frame(width: geometry.size.width * zonePercentage(.three), height: 48)
                                    
                                    Label {
                                        HStack {
                                            Text(formatTimeInterval(healthController.timeInZones[.three] ?? 0))
                                            Spacer()
                                            if zone == .three {
                                                HeartPulse()
                                            }
                                        }
                                    } icon: {
                                        Image(systemName: "3.circle")
                                    }
                                    .padding(.leading, 12)
                                }
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(OZone.four.color().opacity(0.7))
                                        .frame(width: geometry.size.width * zonePercentage(.four), height: 48)
                                    
                                    Label {
                                        HStack {
                                            Text(formatTimeInterval(healthController.timeInZones[.four] ?? 0))
                                            Spacer()
                                            if zone == .four {
                                                HeartPulse()
                                            }
                                        }
                                    } icon: {
                                        Image(systemName: "4.circle")
                                    }
                                    .padding(.leading, 12)
                                }
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .foregroundStyle(OZone.five.color().opacity(0.7))
                                        .frame(width: geometry.size.width * zonePercentage(.five), height: 48)
                                    
                                    Label {
                                        HStack {
                                            Text(formatTimeInterval(healthController.timeInZones[.five] ?? 0))
                                            Spacer()
                                            if zone == .five {
                                                HeartPulse()
                                            }
                                        }
                                    } icon: {
                                        Image(systemName: "5.circle")
                                    }
                                    .padding(.leading, 12)
                                }
                            }
                        }
                    }
                    .font(.title.monospacedDigit().lowercaseSmallCaps())
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Helper function to calculate the percentage width for each zone
    private func zonePercentage(_ zone: OZone) -> Double {
        let totalTime = healthController.timeInZones.values.reduce(0, +)
        guard totalTime > 0 else { return 0 }
        
        return (healthController.timeInZones[zone] ?? 0) / totalTime * 0.92
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
        .environment(HealthController())
}
