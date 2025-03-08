//
//  Four78StepsSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct Four78StepsSection: View {
    var body: some View {
        DisclosureGroup(stepsLabel) {
            Label("Breathe in calmly through your nose for a count of 4.", systemImage: 1.countSystemImage())
            Label("Hold for a count of 7.", systemImage: 2.countSystemImage())
            Label("Breathe out forcefully through your mouth for a count of 8.", systemImage: 3.countSystemImage())
            Label("That's 1 round done! Repeat steps 1-3 each round.", systemImage: 4.countSystemImage())
        }
    }
}

#Preview {
    Four78StepsSection()
}
