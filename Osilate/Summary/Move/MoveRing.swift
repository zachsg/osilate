//
//  MoveRing.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct MoveRing: View {
    var movePercent: Double
    
    var body: some View {
        Circle()
            .stroke(style: .init(lineWidth: 30))
            .foregroundStyle(.move.opacity(0.3))
            .frame(height: 300)
            .overlay {
                Circle()
                    .trim(from: 0, to: movePercent)
                    .stroke(style: .init(lineWidth: 30, lineCap: .round))
                    .rotation(.degrees(270))
                    .foregroundStyle(.move)
                    .shadow(radius: 2)
                    .frame(height: 300)
            }
    }
}

#Preview {
    MoveRing(movePercent: 0.7)
}
