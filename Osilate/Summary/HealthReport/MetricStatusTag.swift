//
//  MetricStatusTag.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/13/25.
//

import SwiftUI

struct MetricStatusTag: View {
    let title: String
    let systemName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.caption2)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 2, height: 2)))
    }
}

#Preview {
    MetricStatusTag(title: "Normal", systemName: inRangeSystemImage, color: .green)
}
