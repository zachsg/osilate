//
//  BreatheRing.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct BreatheRing: View {
    var breathePercent: Double
    
    var body: some View {
        Circle()
            .stroke(style: .init(lineWidth: 30))
            .foregroundStyle(.breathe.opacity(0.3))
            .frame(height: 180)
            .overlay {
                Circle()
                    .trim(from: 0, to: breathePercent)
                    .stroke(style: .init(lineWidth: 30, lineCap: .round))
                    .rotation(.degrees(270))
                    .foregroundStyle(.breathe)
                    .frame(height: 180)
            }
    }
}

#Preview {
    BreatheRing(breathePercent: 0.7)
}
