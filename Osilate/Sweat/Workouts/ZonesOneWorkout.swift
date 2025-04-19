//
//  ZonesOneWorkout.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/19/25.
//

import Charts
import HealthKit
import SwiftUI

struct ZonesOneWorkout: View {
    @Environment(HealthController.self) private var healthController
    
    var workout: HKWorkout
    @Binding var sheetIsShowing: Bool
    
    @State private var chartType: ChartType = .bar
    @State private var zoneDurations: [OZone: TimeInterval] = [:]
    @State private var loading = true
    
    enum ChartType: String, CaseIterable {
        case bar, pie
    }
    
    struct ZoneAndMinutes: Identifiable {
        var id = UUID()
        var minutes: Int
        var zone: OZone
    }
    
    var zonesAndMinutes: [ZoneAndMinutes] {
        var zonesAndMinutes = [ZoneAndMinutes]()
        
        for zone in zoneDurations.keys {
            if zone != .one {
                let minutes = Int(((zoneDurations[zone] ?? 0) / 60).rounded(toPlaces: 1))
                let zoneAndMinutes = ZoneAndMinutes(minutes: minutes, zone: zone)
                
                zonesAndMinutes.append(zoneAndMinutes)
            }
        }
        
        zonesAndMinutes.sort { $0.zone > $1.zone }
        
        return zonesAndMinutes
    }
    
    var chartSystemImage: String {
        chartType == .pie ? "chart.pie" : "chart.bar"
    }
    
    var noZones: Bool {
        var time: TimeInterval = 0
        
        for zone in zoneDurations.keys {
            if zone != .one {
                time += zoneDurations[zone] ?? 0
            }
        }
        
        return time == 0
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Chart Style", selection: $chartType.animation()) {
                    ForEach(ChartType.allCases, id: \.self) { type in
                        Label(type.rawValue.capitalized, systemImage: type == .pie ? "chart.pie" : "chart.bar")
                            .labelStyle(.iconOnly)
                    }
                }
                .pickerStyle(.segmented)
                
                ZStack {
                    Chart {
                        ForEach(zonesAndMinutes) { zoneAndMinutes in
                            if chartType == .pie {
                                SectorMark(angle: .value("Zone", zoneAndMinutes.minutes))
                                    .foregroundStyle(zoneAndMinutes.zone.color())
                                    .annotation(position: .overlay) {
                                        if !noZones {
                                            let total = zonesAndMinutes.map { $0.minutes }.reduce(0, +)
                                            let percentage = (Double(zoneAndMinutes.minutes) / Double(total)).rounded(toPlaces: 2)
                                            
                                            Text(percentage, format: .percent)
                                                .font(.caption.bold())
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(.thinMaterial)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                        }
                                    }
                            } else {
                                BarMark(
                                    x: .value("Minutes", zoneAndMinutes.minutes),
                                    y: .value("Zone", zoneAndMinutes.zone.rawValue)
                                )
                                .foregroundStyle(zoneAndMinutes.zone.color())
                                .annotation(position: .trailing) {
                                    if !noZones {
                                        HStack(spacing: 1) {
                                            Text(zoneAndMinutes.minutes, format: .number)
                                                .fontWeight(.bold)
                                            Text("min")
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 4)
                                    }
                                }
                            }
                        }
                    }
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                    .chartForegroundStyleScale([/*"1": OZone.one.color(),*/ OZone.two.rawValue: OZone.two.color(), OZone.three.rawValue: OZone.three.color(), OZone.four.rawValue: OZone.four.color(), OZone.five.rawValue: OZone.five.color()])
                    .chartLegend(.visible)
                    
                    if loading {
                        ProgressView()
                    } else if noZones {
                        Text("No workouts with Zone 2+ heart rate found.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(4)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding([.bottom, .leading, .trailing], 8)
            .navigationTitle("Workout HR Zones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        sheetIsShowing.toggle()
                    } label: {
                        Label {
                            Text(closeLabel)
                        } icon: {
                            Image(systemName: cancelSystemImage)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                let zones = await healthController.fetchZones(for: [workout])
                
                await MainActor.run {
                    zoneDurations = zones
                    loading = false
                }
            }
        }
    }
}

#Preview {
    ZonesOneWorkout(workout: MockWorkout().createMockWorkout(), sheetIsShowing: .constant(true))
        .environment(HealthController())
}
