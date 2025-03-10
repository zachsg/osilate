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
        HStack(spacing: 24) {
            Spacer()
            
            ZStack {
                ActivityRing(percent: percent, color: color, strokeWidth: 20, height: 110)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
                
                Text(percent, format: .percent)
                    .font(.title2.bold())
                    .foregroundStyle(color)
                    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
            }
            .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(showToday ? "TODAY" : "PAST 7 DAYS")
                    .font(.headline.bold())
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
    ActivityRingAndStats(percent: 0.75, color: Color.blue) {
        VStack(alignment: .leading, spacing: 0) {
            Text("Steps")
                .font(.caption)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(7500, format: .thousandsAbbr)
                    .font(.title2.bold())
                    .foregroundStyle(.move)
                
                HStack(spacing: 2) {
                    Text("of")
                    Text(10000, format: .thousandsAbbr)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.secondary)
                .font(.caption)
            }
        }
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Miles")
                .font(.caption)
            
            Text(5.4.rounded(toPlaces: 1), format: .number)
                .font(.title2.bold())
                .foregroundStyle(.move)
        }
    }
}
