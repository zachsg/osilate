//
//  OverallReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct OverallReport: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var bodyTempStatus: BodyMetricStatus?
    @Binding var respirationStatus: BodyMetricStatus?

    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 32) {
                    VStack {
                        if healthController.bodyTempByDayLoading {
                            ProgressView()
                        } else {
                            Image(systemName: bodyTempStatus == .normal ? bodyTempNormalSystemImage : bodyTempStatus == .low ? bodyTempLowSystemImage : bodyTempHighSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.accent)
                            
                            Image(systemName: bodyTempStatus == .normal ? inRangeSystemImage : outRangeSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(bodyTempStatus == .normal ? .green : .red)
                        }
                    }
                    
                    VStack {
                        if healthController.respirationByDayLoading {
                            ProgressView()
                        } else {
                            Image(systemName: respirationSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.accent)
                            
                            Image(systemName: respirationStatus == .normal ? inRangeSystemImage : outRangeSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(respirationStatus == .normal ? .green : .red)
                        }
                    }
                }
            }
        } header: {
            HeaderLabel(title: overallTitle, systemImage: overallSystemImage)
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    return OverallReport(bodyTempStatus: .constant(.normal), respirationStatus: .constant(.normal))
        .environment(healthController)
}
