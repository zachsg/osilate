//
//  StreakItem.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct StreakItem: View {
    @Environment(\.colorScheme) var colorScheme
    
    var label: String
    var streak: Int
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("\(streak)")
                    .font(.title.bold())
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("day")
                        
                    Text("streak")
                }
                .font(.caption2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 2)
            .background(.breathe)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 6, height: 6)))
            .padding(.horizontal, 2)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StreakItem(label: "Meditate", streak: 2)
}
