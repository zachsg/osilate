//
//  Four78LearnMoreSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct Four78LearnMoreSection: View {
    var body: some View {
        DisclosureGroup(resourcesLabel) {
            Link("Andrew Weil", destination: URL(string: "https://www.drweil.com/videos-features/videos/breathing-exercises-4-7-8-breath/")!)
        
            Link("Cleveland Clinic", destination: URL(string: "https://health.clevelandclinic.org/4-7-8-breathing")!)
        
            Link("WebMD", destination: URL(string: "https://www.webmd.com/balance/what-to-know-4-7-8-breathing")!)
        }
    }
}

#Preview {
    Four78LearnMoreSection()
}
