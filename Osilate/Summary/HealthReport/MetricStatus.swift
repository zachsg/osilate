//
//  MetricStatus.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/12/25.
//

import SwiftUI

struct MetricStatus<Content: View>: View {
    let title: String
    let status: BodyMetricStatus?
    let systemImageName: String
    var systemImageNameLow: String = ""
    var systemImageNameHigh: String = ""
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            ZStack {
                Circle()
                    .frame(width: 54, height: 54)
                    .foregroundStyle(.regularMaterial)
                
                VStack {
                    Image(systemName: systemName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(.accent)
                    
                    content
                }
            }
            .shadow(radius: 1)
            
            Image(systemName: (status ?? .missing).systemName())
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle((status ?? .missing).color())
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
    MetricStatus(title: "O2", status: .normal, systemImageName: oxygenSystemImage) {
        Text(0.97.rounded(toPlaces: 2), format: .percent)
            .font(.caption2.bold())
    }
}
