//
//  StatsView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct StatsSheet: View {
    @Binding var showingSheet: Bool
    
    @State private var timeFrame: OTimeFrame = .sevenDays
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $timeFrame.animation(), label: Text("Time Frame")) {
                    ForEach(OTimeFrame.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .padding([.top, .leading, .trailing])
                .pickerStyle(.segmented)
                
                TimeSpentChart(timeFrame: $timeFrame)
            }
            .navigationTitle(statsTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        showingSheet.toggle()
                    } label: {
                        Label(closeLabel, systemImage: cancelSystemImage)
                    }
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    StatsSheet(showingSheet: .constant(true))
}
