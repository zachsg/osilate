//
//  HealthReportSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

enum BodyMetricStatus {
    case low, normal, high
}

struct HealthReportSheet: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var sheetIsShowing: Bool
    
    @State private var bodyTempHigh = 0.0
    @State private var bodyTempLow = 0.0
    @State private var bodyTemp = 0.0
    @State private var bodyTempStatus: BodyMetricStatus?
    
    @State private var respirationHigh = 0.0
    @State private var respirationLow = 0.0
    @State private var respiration = 0.0
    @State private var respirationStatus: BodyMetricStatus?
    
    @State private var oxygenHigh = 0.0
    @State private var oxygenLow = 0.0
    @State private var oxygen = 0.0
    @State private var oxygenStatus: BodyMetricStatus?
    
    @State private var rhrHigh = 0
    @State private var rhrLow = 0
    @State private var rhr = 0
    @State private var rhrStatus: BodyMetricStatus?
    
    var body: some View {
        NavigationStack {
            Form {
                OverallReport(bodyTempStatus: $bodyTempStatus, respirationStatus: $respirationStatus)
                
                BodyTempReport(bodyTempHigh: $bodyTempHigh, bodyTempLow: $bodyTempLow, bodyTemp: $bodyTemp, bodyTempStatus: $bodyTempStatus)
                
                RespirationReport(respirationHigh: $respirationHigh, respirationLow: $respirationLow, respiration: $respiration, respirationStatus: $respirationStatus)
                
                Section {
                    HStack(spacing: 2) {
                        Text(healthController.rhrMostRecent, format: .number)
                        Text("BPM")
                    }
                } header: {
                    HeaderLabel(title: "Resting Heart Rate", systemImage: "heart.fill")
                } footer: {
                    Text("Units: Beats per minute.")
                }
                
                Section {
                    Text(Int((healthController.oxygenToday * 100).rounded()), format: .percent)
                } header: {
                    HeaderLabel(title: "Blood Oxygen", systemImage: "drop.degreesign.fill")
                }
                
                Section {
                    Text("Coming soon...")
                } header: {
                    HeaderLabel(title: "Sleep Duration", systemImage: "bed.double.fill")
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
            healthController.getRhrRecent()
            
            healthController.getBodyTempToday()
            healthController.getBodyTempTwoWeeks()
            
            healthController.getRespirationToday()
            healthController.getRespirationTwoWeeks()
            
            healthController.getOxygenToday()
            healthController.getOxygenTwoWeeks()
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.bodyTempToday = 98
    healthController.respirationToday = 14
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.bodyTempByDay[date] = Double(Int.random(in: 94...101))
            healthController.respirationByDay[date] = Double(Int.random(in: 13...18))
        }
    }
    
    return HealthReportSheet(sheetIsShowing: .constant(true))
        .environment(healthController)
}
