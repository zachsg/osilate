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
    
    var metrics: (inRange: Int, total: Int) {
        var total = 0
        var inRange = 0
        
        switch healthController.bodyTempStatus {
        case .normal, .optimal:
            inRange += 1
            total += 1
        default:
            total += 1
        }
        
        switch healthController.respirationStatus {
        case .normal, .optimal:
            inRange += 1
            total += 1
        default:
            total += 1
        }
        
        switch healthController.oxygenStatus {
        case .normal, .optimal:
            inRange += 1
            total += 1
        default:
            total += 1
        }
        
        switch healthController.rhrStatus {
        case .normal, .optimal:
            inRange += 1
            total += 1
        default:
            total += 1
        }
        
        switch healthController.hrvStatus {
        case .normal, .optimal:
            inRange += 1
            total += 1
        default:
            total += 1
        }
        
        switch healthController.sleepStatus {
        case .normal, .optimal:
            inRange += 1
            total += 1
        default:
            total += 1
        }
        
        return (inRange: inRange, total: total)
    }

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    if hasBodyTemp {
                        if healthController.bodyTempByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Temp", status: healthController.bodyTempStatus, systemImageName: bodyTempNormalSystemImage, systemImageNameLow: bodyTempLowSystemImage, systemImageNameHigh: bodyTempHighSystemImage) {
                                HStack(alignment: .firstTextBaseline, spacing: 1) {
                                    Text(healthController.bodyTempToday.rounded(toPlaces: 1), format: .number)
                                    Text("°")
                                }
                                .font(.caption2.bold())
                            }
                            .padding(.leading, 4)
                        }
                    }
                    
                    if hasRespiration {
                        if healthController.respirationByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Resp", status: healthController.respirationStatus, systemImageName: respirationSystemImage) {
                                Text(healthController.respirationToday.rounded(toPlaces: 1), format: .number)
                                    .font(.caption2.bold())
                            }
                        }
                    }
                
                    if hasOxygen {
                        if healthController.oxygenByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "O2", status: healthController.oxygenStatus, systemImageName: oxygenSystemImage) {
                                Text((healthController.oxygenToday / 100).rounded(toPlaces: 3), format: .percent)
                                    .font(.caption2.bold())
                            }
                        }
                    }
                
                    if hasRhr {
                        if healthController.rhrLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "RHR", status: healthController.rhrStatus, systemImageName: rhrSystemImage) {
                                Text(healthController.rhrMostRecent, format: .number)
                                    .font(.caption2.bold())
                            }
                        }
                    }
                    
                    if hasHrv {
                        if healthController.hrvLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "HRV", status: healthController.hrvStatus, systemImageName: hrvSystemImage) {
                                Text(healthController.hrvToday.rounded(toPlaces: 0), format: .number)
                                    .font(.caption2.bold())
                            }
                        }
                    }
                    
                    if hasSleep {
                        if healthController.sleepLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Sleep", status: healthController.sleepStatus, systemImageName: sleepSystemImage) {
                                HStack(alignment: .firstTextBaseline, spacing: 1) {
                                    Text(healthController.sleepToday.rounded(toPlaces: 1), format: .number)
                                    Text("h")
                                }
                                .font(.caption2.bold())
                            }
                        }
                    }
                }
            }
        } header: {
            HeaderLabel(title: "\(overallTitle) (\(metrics.inRange)/\(metrics.total) in range)", systemImage: overallSystemImage)
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
