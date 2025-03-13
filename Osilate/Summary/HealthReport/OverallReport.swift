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
    
    @Binding var bodyTempStatus: BodyMetricStatus?
    @Binding var respirationStatus: BodyMetricStatus?
    @Binding var oxygenStatus: BodyMetricStatus?
    @Binding var rhrStatus: BodyMetricStatus?

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 24) {
                    if hasBodyTemp {
                        if healthController.bodyTempByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Temp", status: bodyTempStatus, systemImageName: bodyTempNormalSystemImage, systemImageNameLow: bodyTempLowSystemImage, systemImageNameHigh: bodyTempHighSystemImage)
                        }
                    }
                    
                    if hasRespiration {
                        if healthController.respirationByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "Resp", status: respirationStatus, systemImageName: respirationSystemImage)
                        }
                    }
                
                    if hasOxygen {
                        if healthController.oxygenByDayLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "O2", status: oxygenStatus, systemImageName: oxygenSystemImage)
                        }
                    }
                
                    if hasRhr {
                        if healthController.rhrLoading {
                            ProgressView()
                        } else {
                            MetricStatus(title: "RHR", status: rhrStatus, systemImageName: rhrSystemImage)
                        }
                    }
                }
                .padding(2)
            }
        } header: {
            HeaderLabel(title: overallTitle, systemImage: overallSystemImage)
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    return OverallReport(bodyTempStatus: .constant(.normal), respirationStatus: .constant(.normal), oxygenStatus: .constant(.normal), rhrStatus: .constant(.normal))
        .environment(healthController)
}
