//
//  ODisclosureGroupStyle.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import Foundation
import SwiftUI

struct ODisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack {
                    configuration.label
                }
                .buttonStyle(PlainButtonStyle())
            }
            if configuration.isExpanded {
                configuration.content
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .identity))
            }
        }
    }
}
