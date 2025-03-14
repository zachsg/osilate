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
    
    @State private var tempRangeTop = 0.1
    @State private var tempRangeBottom = -0.1
    @State private var tempMeasuredTop = 0.0
    @State private var tempMeasuredBottom = 0.0
    @State private var tempStatus: BodyMetricStatus?
    
    @State private var respirationRangeTop = 0.1
    @State private var respirationRangeBottom = -0.1
    @State private var respirationMeasuredTop = 0.0
    @State private var respirationMeasuredBottom = -0.0
    @State private var respirationStatus: BodyMetricStatus?
    
    @State private var oxygenRangeTop = 0.1
    @State private var oxygenRangeBottom = -0.1
    @State private var oxygenMeasuredTop = 0.0
    @State private var oxygenMeasuredBottom = 0.0
    @State private var oxygenStatus: BodyMetricStatus?
    
    @State private var rhrRangeTop = 1
    @State private var rhrRangeBottom = -1
    @State private var rhrMeasuredTop = 0
    @State private var rhrMeasuredBottom = 0
    @State private var rhrStatus: BodyMetricStatus?
    
    @State private var hrvRangeTop = 0.1
    @State private var hrvRangeBottom = -0.1
    @State private var hrvMeasuredTop = 0.0
    @State private var hrvMeasuredBottom = 0.0
    @State private var hrv = 0.0
    @State private var hrvStatus: BodyMetricStatus?
    
    @State private var sleepRangeTop = 0.1
    @State private var sleepRangeBottom = -0.1
    @State private var sleepMeasuredTop = 0.0
    @State private var sleepMeasuredBottom = 0.0
    @State private var sleepStatus: BodyMetricStatus?
    
    var body: some View {
        NavigationStack {
            List {
                OverallReport(bodyTempStatus: $tempStatus, respirationStatus: $respirationStatus, oxygenStatus: $oxygenStatus, rhrStatus: $rhrStatus, hrvStatus: $hrvStatus, sleepStatus: $sleepStatus)
                
                if hasBodyTemp {
                    BodyTempReport(rangeTop: $tempRangeTop, rangeBottom: $tempRangeBottom, measuredTop: $tempMeasuredTop, measuredBottom: $tempMeasuredBottom, status: $tempStatus)
                }
                
                if hasRespiration {
                    RespirationReport(rangeTop: $respirationRangeTop, rangeBottom: $respirationRangeBottom, measuredTop: $respirationMeasuredTop, measuredBottom: $respirationMeasuredBottom, status: $respirationStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasOxygen {
                    OxygenReport(rangeTop: $oxygenRangeTop, rangeBottom: $oxygenRangeBottom, measuredTop: $oxygenMeasuredTop, measuredBottom: $oxygenMeasuredBottom, status: $oxygenStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasRhr {
                    RHRReport(rangeTop: $rhrRangeTop, rangeBottom: $rhrRangeBottom, measuredTop: $rhrMeasuredTop, measuredBottom: $rhrMeasuredBottom, status: $rhrStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasHrv {
                    HRVReport(rangeTop: $hrvRangeTop, rangeBottom: $hrvRangeBottom, measuredTop: $hrvMeasuredTop, measuredBottom: $hrvMeasuredBottom, status: $hrvStatus)
                        .listRowInsets(EdgeInsets())
                }
                
                if hasSleep {
                    SleepReport(rangeTop: $sleepRangeTop, rangeBottom: $sleepRangeBottom, measuredTop: $sleepMeasuredTop, measuredBottom: $sleepMeasuredBottom, status: $sleepStatus)
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
                
                Task {
                    await tempStats()
                }
            }
           
            if hasRespiration {
                healthController.getRespirationToday()
                healthController.getRespirationTwoWeeks()
                
                Task {
                    await respirationStats()
                }
            }
            
            if hasOxygen {
                healthController.getOxygenToday()
                healthController.getOxygenTwoWeeks()
                
                Task {
                    await oxygenStats()
                }
            }
            
            if hasRhr {
                healthController.getRhrRecent()
                
                Task {
                    await rhrStats()
                }
            }
            
            if hasHrv {
                healthController.getHrvToday()
                healthController.getHrvTwoWeeks()
                
                Task {
                    await hrvStats()
                }
            }
            
            if hasSleep {
                healthController.getSleepToday()
                healthController.getSleepTwoWeeks()
                
                Task {
                    await sleepStats()
                }
            }
        }
    }
    
    @MainActor
    func tempStats() async {
        while healthController.bodyTempByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        let stats = BodyMetricCalculations.tempStats(controller: healthController)
        tempRangeTop = stats.rangeTop
        tempRangeBottom = stats.rangeBottom
        tempMeasuredTop = stats.measuredTop
        tempMeasuredBottom = stats.measuredBottom
        tempStatus = stats.status
    }
    
    @MainActor
    func respirationStats() async {
        while healthController.respirationByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        let stats = BodyMetricCalculations.respirationStats(controller: healthController)
        respirationRangeTop = stats.rangeTop
        respirationRangeBottom = stats.rangeBottom
        respirationMeasuredTop = stats.measuredTop
        respirationMeasuredBottom = stats.measuredBottom
        respirationStatus = stats.status
    }
    
    @MainActor
    func oxygenStats() async {
        while healthController.oxygenByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        let stats = BodyMetricCalculations.oxygenStats(controller: healthController)
        oxygenRangeTop = stats.rangeTop
        oxygenRangeBottom = stats.rangeBottom
        oxygenMeasuredTop = stats.measuredTop
        oxygenMeasuredBottom = stats.measuredBottom
        oxygenStatus = stats.status
    }
    
    @MainActor
    func rhrStats() async {
        while healthController.rhrLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        let stats = BodyMetricCalculations.rhrStats(controller: healthController)
        rhrRangeTop = stats.rangeTop
        rhrRangeBottom = stats.rangeBottom
        rhrMeasuredTop = stats.measuredTop
        rhrMeasuredBottom = stats.measuredBottom
        rhrStatus = stats.status
    }
    
    @MainActor
    func hrvStats() async {
        while healthController.hrvByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        let stats = BodyMetricCalculations.hrvStats(controller: healthController)
        hrvRangeTop = stats.rangeTop
        hrvRangeBottom = stats.rangeBottom
        hrvMeasuredTop = stats.measuredTop
        hrvMeasuredBottom = stats.measuredBottom
        hrvStatus = stats.status
    }
    
    @MainActor
    func sleepStats() async {
        while healthController.sleepByDayLoading {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        }
        
        let stats = BodyMetricCalculations.sleepStats(controller: healthController)
        sleepRangeTop = stats.rangeTop
        sleepRangeBottom = stats.rangeBottom
        sleepMeasuredTop = stats.measuredTop
        sleepMeasuredBottom = stats.measuredBottom
        sleepStatus = stats.status
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
