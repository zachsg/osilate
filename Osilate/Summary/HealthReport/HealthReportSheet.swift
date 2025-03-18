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
    
    var body: some View {
        NavigationStack {
            List {
                OverallReport()
                
                Section {
                    if hasBodyTemp {
                        BodyTempReport()
                    }
                    
                    if hasRespiration {
                        RespirationReport()
                    }
                    
                    if hasOxygen {
                        OxygenReport()
                    }
                    
                    if hasRhr {
                        RHRReport()
                    }
                    
                    if hasHrv {
                        HRVReport()
                    }
                    
                    if hasSleep {
                        SleepReport()
                    }
                } header: {
                    HeaderLabel(title: "Past 2 Weeks", systemImage: "calendar")
                } footer: {
                    Text("Tip: Tap on any graph for an expanded view.")
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
    healthController.respirationToday = 14
    healthController.oxygenToday = 97.6
    healthController.hrvToday = 55
    healthController.sleepToday = 6.5
    
    healthController.bodyTempToday = 98.6
    healthController.bodyTempRangeTop = 101
    healthController.bodyTempRangeBottom = 94
    healthController.bodyTempMeasuredTop = 100
    healthController.bodyTempMeasuredBottom = 95
    healthController.hasBodyTempToday = true
    
    let calendar = Calendar.current
    for i in 0...13 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date.now)
        if let date {
            healthController.bodyTempByDay[date] = Double(Int.random(in: 94...101))
            healthController.respirationByDay[date] = Double(Int.random(in: 13...18))
            healthController.oxygenByDay[date] = Double(Int.random(in: 95...98))
            healthController.hrvByDay[date] = Double(Int.random(in: 45...70))
            healthController.sleepByDay[date] = Double(Int.random(in: 5...9))
        }
    }
    
    return HealthReportSheet(sheetIsShowing: .constant(true))
        .environment(healthController)
}
