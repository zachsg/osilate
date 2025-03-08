//
//  StatItem.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct StatItem: View {
    var minutes: Int
    var title: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            VStack {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(minutes)")
                        .font(.title2.weight(.semibold))
                    
                    Text("min")
                        .font(.caption)
                        .padding(.leading, 1)
                }
                
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    StatItem(minutes: 20, title: "Meditate")
}
