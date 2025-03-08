//
//  OverallReport.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct OverallReport: View {
    @Environment(HealthController.self) private var healthController
    
    let bodyTempHealthyRange: (low: Double, high: Double)
    let todayTempStatus: BodyTempStatus
    
    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 32) {
                    VStack {
                        if healthController.bodyTempByDayLoading {
                            ProgressView()
                        } else {
                            Image(systemName: todayTempStatus == .normal ? bodyTempNormalSystemImage : todayTempStatus == .low ? bodyTempLowSystemImage : bodyTempHighSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.accent)
                            
                            Image(systemName: todayTempStatus == .normal ? inRangeSystemImage : outRangeSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(todayTempStatus == .normal ? .green : .red)
                        }
                    }
                }
            }
        } header: {
            HeaderView {
                Label(overallTitle, systemImage: overallSystemImage)
            }
        }
    }
}

#Preview {
    let healthController = HealthController()
    
    let bodyTempHealthRange = (97.0, 98.0)
    
    return OverallReport(bodyTempHealthyRange: bodyTempHealthRange, todayTempStatus: .normal)
        .environment(healthController)
}
