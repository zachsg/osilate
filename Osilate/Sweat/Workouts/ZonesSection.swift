//
//  ZonesSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/18/25.
//

import Charts
import SwiftUI

struct ZonesSection: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var zoneDurations: [OZone: TimeInterval]
    @Binding var loading: Bool
    @Binding var showToday: Bool
    
    @State private var chartType: ChartType = .bar
    
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
            if zone != .zero && zone != .one {
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
            if zone != .zero && zone != .one {
                time += zoneDurations[zone] ?? 0
            }
        }
        
        return time == 0
    }
    
    var body: some View {
        Section {
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
            .frame(height: 200)
        } header: {
            HeaderLabel(title: "Workout HR Zones \(showToday ? "Today" : "Past Week")", systemImage: chartSystemImage, color: .accent)
        }
    }
}

#Preview {
    let zoneDurations: [OZone: TimeInterval] = [
        .one: 14122.41491,
        .two: 2804.376657009,
        .three: 3664.965806,
        .four: 427.9999,
        .five: 0,
    ]
    
    ZonesSection(zoneDurations: .constant(zoneDurations), loading: .constant(false), showToday: .constant(false))
        .environment(HealthController())
}
