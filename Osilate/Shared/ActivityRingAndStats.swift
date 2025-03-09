//
//  ActivityRingAndStats.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/9/25.
//

import SwiftUI

struct ActivityRingAndStats<Content: View>: View {
    @AppStorage(showTodayKey) var showToday = showTodayDefault
    
    let percent: Double
    let color: Color
    
    @ViewBuilder let content: Content
    
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            Spacer()
            
            ZStack {
                ActivityRing(percent: percent, color: color, strokeWidth: 20, height: 100)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
                
                Text(percent, format: .percent)
                    .font(.title2.bold())
                    .foregroundStyle(color)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
            }
            .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(showToday ? "Today" : "Past 7 Days")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    content
                }
            }
            
            Spacer()
        }
        .padding(.vertical)
        .onTapGesture {
            withAnimation {
                animationAmount = animationAmount == 0 ? 180 : 0
                showToday.toggle()
            }
        }
    }
}

#Preview {
    ActivityRingAndStats(percent: 0.7, color: Color.blue) {
        HStack(spacing: 2) {
            Text(7000, format: .number)
                .font(.title.bold())
            
            VStack(alignment: .leading, spacing: 0) {
                Text("steps")
                HStack(spacing: 4) {
                    Text("of")
                    Text(10000, format: .thousandsAbbr)
                        .fontWeight(.bold)
                }
            }
            .foregroundStyle(.secondary)
            .font(.caption2)
        }
        
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(5.2, format: .number)
                .font(.title.bold())
            Text("miles")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
