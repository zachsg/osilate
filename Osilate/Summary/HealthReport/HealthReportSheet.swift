//
//  HealthReportSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

enum BodyTempStatus {
    case low, normal, high
}

struct HealthReportSheet: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(HealthController.self) private var healthController
    
    @Binding var sheetIsShowing: Bool
    
    @State private var rhr = 55.0

    var color: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var days: (today: Date, yesterday: Date, twoAgo: Date) {
        let now = Date.now
        let twoAgo = now.addingTimeInterval(-86400 * 2)
        let yesterday = now.addingTimeInterval(-86400)
        
        return (now, yesterday, twoAgo)
    }
    
    var bodyTempRange: (low: Double, high: Double) {
        var low = 200.0
        var high = 0.0
        
        for (_, temp) in healthController.bodyTempByDay {
            if temp > high {
                high = temp
            }
            
            if temp < low {
                low = temp
            }
        }
        
        return (low - 1, high + 1)
    }
    
    var bodyTempHealthyRange: (low: Double, high: Double) {
        var average = 0.0
        
        for (_, temp) in healthController.bodyTempByDay {
            average += temp
        }
        
        average /= Double(healthController.bodyTempByDay.count)
        
        return (low: average - 1, high: average + 1)
    }
    
    var todayTempStatus: BodyTempStatus {
        return if healthController.bodyTempToday < bodyTempHealthyRange.low {
            .low
        } else if healthController.bodyTempToday > bodyTempHealthyRange.high {
            .high
        } else {
            .normal
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                OverallReport(
                    bodyTempHealthyRange: bodyTempHealthyRange,
                    todayTempStatus: todayTempStatus
                )
                
                BodyTempReport(
                    bodyTempRange: bodyTempRange,
                    bodyTempHealthyRange: bodyTempHealthyRange,
                    todayTempStatus: todayTempStatus
                )
                
                Section {
                    Text("Coming soon...")
                } header: {
                    Label("Resting Heart Rate", systemImage: "heart.fill")
                } footer: {
                    Text("Units: Beats per minute.")
                }
                
                Section {
                    Text("Coming soon...")
                } header: {
                    Label("Respiration Rate", systemImage: "lungs.fill")
                }
                
                Section {
                    Text("Coming soon...")
                } header: {
                    Label("Blood Oxygen", systemImage: "drop.degreesign.fill")
                }
                
                Section {
                    Text("Coming soon...")
                } header: {
                    Label("Sleep Duration", systemImage: "bed.double.fill")
                }
            }
            .navigationTitle(healthReportTitle)
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
            healthController.loadBodyTempToday()
            healthController.loadBodyTempTwoWeeks()
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    return HealthReportSheet(sheetIsShowing: .constant(true))
        .environment(healthController)
}
