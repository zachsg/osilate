//
//  ZonesView.swift
//  Osilate Watch Watch App
//
//  Created by Zach Gottlieb on 4/14/25.
//

import SwiftUI

struct ZonesView: View {
    @Environment(WorkoutManager.self) private var workoutManager
    
    @State private var zone1Percent = 1.0
    @State private var zone2Percent = 0.3
    @State private var zone3Percent = 0.0
    @State private var zone4Percent = 0.0
    @State private var zone5Percent = 0.0

    var body: some View {
        ZStack {
            workoutManager.heartRate.zoneColor().opacity(0.2)
            
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.green.opacity(0.7))
                            .frame(width: geometry.size.width * zone1Percent, height: 34)
                        
                        Label {
                            Text("03:15")
                        } icon: {
                            Image(systemName: "1.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.yellow.opacity(0.7))
                            .frame(width: geometry.size.width * zone2Percent, height: 34)
                        
                        Label {
                            Text("03:15")
                        } icon: {
                            Image(systemName: "2.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.orange.opacity(0.7))
                            .frame(width: geometry.size.width * zone3Percent, height: 34)
                        
                        Label {
                            Text("03:15")
                        } icon: {
                            Image(systemName: "3.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.red.opacity(0.7))
                            .frame(width: geometry.size.width * zone4Percent, height: 34)
                        
                        Label {
                            Text("03:15")
                        } icon: {
                            Image(systemName: "4.circle")
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .foregroundStyle(.purple.opacity(0.7))
                            .frame(width: geometry.size.width * zone5Percent, height: 34)
                        
                        Label {
                            Text("03:15")
                        } icon: {
                            Image(systemName: "5.circle")
                        }
                    }
                }
                .font(.title2.monospacedDigit().lowercaseSmallCaps())
                .frame(maxWidth: .infinity, alignment: .leading)
                .scenePadding()
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZonesView()
        .environment(WorkoutManager())
}
