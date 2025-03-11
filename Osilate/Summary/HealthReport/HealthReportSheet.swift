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
    @State private var bodyTempStatus: BodyMetricStatus?
    
    @State private var respirationHigh = 0.0
    @State private var respirationLow = 0.0
    @State private var respirationStatus: BodyMetricStatus?
    
    @State private var oxygenHigh = 0.0
    @State private var oxygenLow = 0.0
    @State private var oxygenStatus: BodyMetricStatus?
    
    @State private var rhrHigh = 0
    @State private var rhrLow = 0
    @State private var rhr = 0
    @State private var rhrStatus: BodyMetricStatus?
    
    var body: some View {
        NavigationStack {
            Form {
                OverallReport(bodyTempStatus: $bodyTempStatus, respirationStatus: $respirationStatus, oxygenStatus: $oxygenStatus, rhrStatus: $rhrStatus)
                
                BodyTempReport(bodyTempHigh: $bodyTempHigh, bodyTempLow: $bodyTempLow, bodyTempStatus: $bodyTempStatus)
                
                RespirationReport(respirationHigh: $respirationHigh, respirationLow: $respirationLow, respirationStatus: $respirationStatus)
               
                OxygenReport(oxygenHigh: $oxygenHigh, oxygenLow: $oxygenLow, oxygenStatus: $oxygenStatus)
                
                RHRReport(rhrHigh: $rhrHigh, rhrLow: $rhrLow, rhrStatus: $rhrStatus)
                
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
            healthController.getBodyTempToday()
            healthController.getBodyTempTwoWeeks()
            
            healthController.getRespirationToday()
            healthController.getRespirationTwoWeeks()
            
            healthController.getOxygenToday()
            healthController.getOxygenTwoWeeks()
            
            healthController.getRhrRecent()
        }
    }
}

#Preview {
    let healthController = HealthController()
    healthController.bodyTempToday = 98
    healthController.respirationToday = 14
    healthController.oxygenToday = 97.6
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.bodyTempByDay[date] = Double(Int.random(in: 94...101))
            healthController.respirationByDay[date] = Double(Int.random(in: 13...18))
            healthController.oxygenByDay[date] = Double(Int.random(in: 95...98))
        }
    }
    
    return HealthReportSheet(sheetIsShowing: .constant(true))
        .environment(healthController)
}
