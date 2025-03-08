//
//  SweatRing.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct SweatRing: View {
    var sweatPercent: Double
    
    var body: some View {
        Circle()
            .stroke(style: .init(lineWidth: 30))
            .foregroundStyle(.sweat.opacity(0.3))
            .frame(height: 240)
            .overlay {
                Circle()
                    .trim(from: 0, to: sweatPercent)
                    .stroke(style: .init(lineWidth: 30, lineCap: .round))
                    .rotation(.degrees(270))
                    .foregroundStyle(.sweat)
                    .shadow(radius: 2)
                    .frame(height: 240)
            }
    }
}

#Preview {
    SweatRing(sweatPercent: 0.7)
}
