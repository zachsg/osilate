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
            StreaksSection()
        } header: {
            HeaderLabel(title: "Progress", systemImage: streaksSystemImage)
        }
    }
}

#Preview(traits: .sampleData) {
    StatsSection()
}
