//
//  StatsSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import SwiftUI

struct StatsSection: View {
    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
//                    MinutesSection()
                    
                    StreaksSection()
                }
            }
            .padding(.top, 4)
        } header: {
            Label("Progress", systemImage: streaksSystemImage)
                .font(.footnote.bold())
                .foregroundStyle(.accent)
        }
    }
}

#Preview(traits: .sampleData) {
    StatsSection()
}
