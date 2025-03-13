//
//  MetricStatus.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/12/25.
//

import SwiftUI

struct MetricStatus: View {
    let title: String
    let status: BodyMetricStatus?
    let systemImageName: String
    var systemImageNameLow: String = ""
    var systemImageNameHigh: String = ""
    
    var body: some View {
        VStack {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            ZStack {
                Circle()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.regularMaterial)
                
                Image(systemName: systemName())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.accent)
            }
            .shadow(radius: 1)
            
            Image(systemName: status == .normal ? inRangeSystemImage : status == .optimal ? optimalRangeSystemImage : status == .missing ? missingRangeSystemImage : outRangeSystemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(status == .normal ? .green : status == .optimal ? .yellow : status == .missing ? .secondary : .red)
        }
    }
    
    private func systemName() -> String {
        let systemName = switch status {
        case .low:
            systemImageNameLow
        case .normal, .optimal, .missing, nil:
            systemImageName
        case .high:
            systemImageNameHigh
        }
        
        return systemName.isEmpty ? systemImageName : systemName
    }
}

#Preview {
    MetricStatus(title: "Resp", status: .normal, systemImageName: bodyTempNormalSystemImage, systemImageNameLow: bodyTempLowSystemImage, systemImageNameHigh: bodyTempHighSystemImage)
}
