//
//  HealthReportSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Charts
import SwiftUI

struct HealthReportSheet: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(hasBodyTempKey) var hasBodyTemp = hasBodyTempDefault
    @AppStorage(hasRespirationKey) var hasRespiration = hasRespirationDefault
    @AppStorage(hasOxygenKey) var hasOxygen = hasOxygenDefault
    @AppStorage(hasRhrKey) var hasRhr = hasRhrDefault
    @AppStorage(hasHrvKey) var hasHrv = hasHrvDefault
    @AppStorage(hasSleepKey) var hasSleep = hasSleepDefault

    @Binding var sheetIsShowing: Bool
    
    @State private var optionsSheetIsShowing = false
    
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
    
    @State private var hrvHigh = 0.0
    @State private var hrvLow = 0.0
    @State private var hrv = 0.0
    @State private var hrvStatus: BodyMetricStatus?
    
    @State private var sleepHigh = 0.0
    @State private var sleepLow = 0.0
    @State private var sleep = 0.0
    @State private var sleepStatus: BodyMetricStatus?
    
    var body: some View {
        NavigationStack {
            List {
                OverallReport(bodyTempStatus: $bodyTempStatus, respirationStatus: $respirationStatus, oxygenStatus: $oxygenStatus, rhrStatus: $rhrStatus, hrvStatus: $hrvStatus, sleepStatus: $sleepStatus)
                
                if hasBodyTemp {
                    BodyTempReport(bodyTempHigh: $bodyTempHigh, bodyTempLow: $bodyTempLow, bodyTempStatus: $bodyTempStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasRespiration {
                    RespirationReport(respirationHigh: $respirationHigh, respirationLow: $respirationLow, respirationStatus: $respirationStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasOxygen {
                    OxygenReport(oxygenHigh: $oxygenHigh, oxygenLow: $oxygenLow, oxygenStatus: $oxygenStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasRhr {
                    RHRReport(rhrHigh: $rhrHigh, rhrLow: $rhrLow, rhrStatus: $rhrStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasHrv {
                    HRVReport(hrvHigh: $hrvHigh, hrvLow: $hrvLow, hrvStatus: $hrvStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasSleep {
                    SleepReport(sleepHigh: $sleepHigh, sleepLow: $sleepLow, sleepStatus: $sleepStatus)
                        .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle(healthReportTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        optionsSheetIsShowing.toggle()
                    } label: {
                        Label {
                            Text("Metric Options")
                        } icon: {
                            Image(systemName: optionsSystemImage)
                        }
                    }
                }
                
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
            .sheet(isPresented: $optionsSheetIsShowing) {
                ReportOptionsSheet(sheetIsShowing: $optionsSheetIsShowing)
            }
        }
        .onAppear {
            if hasBodyTemp {
                healthController.getBodyTempToday()
                healthController.getBodyTempTwoWeeks()
            }
           
            if hasRespiration {
                healthController.getRespirationToday()
                healthController.getRespirationTwoWeeks()
            }
            
            if hasOxygen {
                healthController.getOxygenToday()
                healthController.getOxygenTwoWeeks()
            }
            
            if hasRhr {
                healthController.getRhrRecent()
            }
            
            if hasHrv {
                healthController.getHrvToday()
                healthController.getHrvTwoWeeks()
            }
            
            if hasSleep {
                healthController.getSleepToday()
                healthController.getSleepTwoWeeks()
            }
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
