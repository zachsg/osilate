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
    @Binding var oxygenStatus: BodyMetricStatus?
    @Binding var rhrStatus: BodyMetricStatus?

    var body: some View {
        Section {
            HStack {
                Spacer()
                
                VStack {
                    if healthController.bodyTempByDayLoading {
                        ProgressView()
                    } else {
                        ZStack {
                            Circle()
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.regularMaterial)
                            
                            Image(systemName: bodyTempStatus == .normal ? bodyTempNormalSystemImage : bodyTempStatus == .low ? bodyTempLowSystemImage : bodyTempHighSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.accent)
                        }
                        .shadow(radius: 1)
                        
                        Image(systemName: bodyTempStatus == .normal ? inRangeSystemImage : outRangeSystemImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(bodyTempStatus == .normal ? .green : .red)
                    }
                }
                
                Spacer()
                
                VStack {
                    if healthController.respirationByDayLoading {
                        ProgressView()
                    } else {
                        ZStack {
                            Circle()
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.regularMaterial)
                            
                            Image(systemName: respirationSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.accent)
                        }
                        .shadow(radius: 1)
                        
                        Image(systemName: respirationStatus == .normal ? inRangeSystemImage : outRangeSystemImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(respirationStatus == .normal ? .green : .red)
                    }
                }
                
                Spacer()
                
                VStack {
                    if healthController.oxygenByDayLoading {
                        ProgressView()
                    } else {
                        ZStack {
                            Circle()
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.regularMaterial)
                            
                            Image(systemName: oxygenSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.accent)
                        }
                        .shadow(radius: 1)
                        
                        Image(systemName: oxygenStatus == .normal ? inRangeSystemImage : outRangeSystemImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(oxygenStatus == .normal ? .green : .red)
                    }
                }
                
                Spacer()
                
                VStack {
                    if healthController.rhrLoading {
                        ProgressView()
                    } else {
                        ZStack {
                            Circle()
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.regularMaterial)
                            
                            Image(systemName: rhrSystemImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.accent)
                        }
                        .shadow(radius: 1)

                        Image(systemName: rhrStatus == .normal ? inRangeSystemImage : outRangeSystemImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(rhrStatus == .normal ? .green : .red)
                    }
                }
                
                Spacer()
            }
            .padding(2)
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
