//
//  OverallReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct OverallReport: View {
    @Environment(HealthController.self) private var healthController
    
    @AppStorage(hasBodyTempKey) var hasBodyTemp = hasBodyTempDefault
    @AppStorage(hasRespirationKey) var hasRespiration = hasRespirationDefault
    @AppStorage(hasOxygenKey) var hasOxygen = hasOxygenDefault
    @AppStorage(hasRhrKey) var hasRhr = hasRhrDefault
    @AppStorage(hasHrvKey) var hasHrv = hasHrvDefault
    @AppStorage(hasSleepKey) var hasSleep = hasSleepDefault

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    if hasBodyTemp {
                        if healthController.bodyTempByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Temp", status: healthController.bodyTempStatus, systemImageName: bodyTempNormalSystemImage, systemImageNameLow: bodyTempLowSystemImage, systemImageNameHigh: bodyTempHighSystemImage)
                        }
                    }
                    
                    if hasRespiration {
                        if healthController.respirationByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Resp", status: healthController.respirationStatus, systemImageName: respirationSystemImage)
                        }
                    }
                
                    if hasOxygen {
                        if healthController.oxygenByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "O2", status: healthController.oxygenStatus, systemImageName: oxygenSystemImage)
                        }
                    }
                
                    if hasRhr {
                        if healthController.rhrLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "RHR", status: healthController.rhrStatus, systemImageName: rhrSystemImage)
                        }
                    }
                    
                    if hasHrv {
                        if healthController.hrvLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "HRV", status: healthController.hrvStatus, systemImageName: hrvSystemImage)
                        }
                    }
                    
                    if hasSleep {
                        if healthController.sleepLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Sleep", status: healthController.sleepStatus, systemImageName: sleepSystemImage)
                        }
                    }
                }
            }
        } header: {
            HeaderLabel(title: overallTitle, systemImage: overallSystemImage)
        } footer: {
            ScrollView(.horizontal) {
                HStack {
                    MetricStatusTag(title: "Optimal", systemName: optimalRangeSystemImage, color: .yellow)
                    MetricStatusTag(title: "Normal", systemName: inRangeSystemImage, color: .green)
                    MetricStatusTag(title: "Unusual", systemName: outRangeSystemImage, color: .red)
                    MetricStatusTag(title: "Missing", systemName: missingRangeSystemImage, color: .secondary)
                }
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    return OverallReport()
        .environment(healthController)
}
