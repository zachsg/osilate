//
//  ZonesView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/15/25.
//

import SwiftUI

struct ZoneBorder: View {
    @Environment(HealthController.self) private var healthController
    
    var zone: OZone
    
    var currentZone: OZone {
        healthController.heartRate.zone()
    }
    
    var body: some View {
        if currentZone == zone {
            RoundedRectangle(cornerRadius: 2)
                .stroke(.white, lineWidth: 4)
        }
    }
}

struct HeartPulse: View {
    @Environment(HealthController.self) private var healthController
    
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
            Text(Int(healthController.heartRate), format: .number)
        }
        .font(.title.bold())
        .padding(.trailing)
        .onAppear {
            isAnimating = true
        }
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
                healthController.heartRate.zoneColor().opacity(0.2)
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .foregroundStyle(.green.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.one), height: 50)
                                .overlay {
                                    ZoneBorder(zone: .one)
                                }
                            
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
                                .foregroundStyle(.yellow.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.two), height: 50)
                                .overlay {
                                    ZoneBorder(zone: .two)
                                }
                            
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
                                .foregroundStyle(.orange.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.three), height: 50)
                                .overlay {
                                    ZoneBorder(zone: .three)
                                }
                            
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
                                .foregroundStyle(.red.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.four), height: 50)
                                .overlay {
                                    ZoneBorder(zone: .four)
                                }
                            
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
                                .foregroundStyle(.purple.opacity(0.7))
                                .frame(width: geometry.size.width * zonePercentage(.five), height: 50)
                                .overlay {
                                    ZoneBorder(zone: .five)
                                }
                            
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
                    .font(.title.monospacedDigit().lowercaseSmallCaps())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scenePadding()
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
