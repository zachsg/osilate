//
//  BoxLearnMoreSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct BoxLearnMoreSection: View {
    var body: some View {
        DisclosureGroup(resourcesLabel) {
            Link("Cleveland Clinic", destination: URL(string: "https://health.clevelandclinic.org/box-breathing-benefits")!)

            Link("WebMD", destination: URL(string: "https://www.webmd.com/balance/what-is-box-breathing")!)
        }
    }
}

#Preview {
    BoxLearnMoreSection()
}
