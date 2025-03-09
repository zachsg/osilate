//
//  ActivityRing.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/9/25.
//

import SwiftUI

struct ActivityRing: View {
    let percent: Double
    let color: Color
    let strokeWidth: Double
    let height: Double
    
    var body: some View {
        Circle()
            .stroke(style: .init(lineWidth: strokeWidth))
            .foregroundStyle(color.opacity(0.3))
            .frame(height: height)
            .overlay {
                Circle()
                    .trim(from: 0, to: percent)
                    .stroke(style: .init(lineWidth: strokeWidth, lineCap: .round))
                    .rotation(.degrees(270))
                    .foregroundStyle(color)
                    .shadow(radius: 1)
                    .frame(height: height)
            }
    }
}

#Preview {
    ActivityRing(percent: 0.7, color: Color.blue, strokeWidth: 20, height: 120)
}
