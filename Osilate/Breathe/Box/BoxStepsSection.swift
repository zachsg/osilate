//
//  BoxStepsSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct BoxStepsSection: View {
    var body: some View {
        DisclosureGroup(stepsLabel) {
            Label("Breathe in throuh your nose for a count of 4.", systemImage: 1.countSystemImage())
            Label("Hold for a count of 4.", systemImage: 2.countSystemImage())
            Label("Breathe out through your nose for a count of 4.", systemImage: 3.countSystemImage())
            Label("Hold for a count of 4.", systemImage: 4.countSystemImage())
            Label("That's 1 round done! Repeat steps 1-4 each round.", systemImage: 5.countSystemImage())
        }
    }
}

#Preview {
    BoxStepsSection()
}
