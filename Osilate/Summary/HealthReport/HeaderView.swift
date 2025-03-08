//
//  HeaderView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct HeaderView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .font(.title3)
            .fontWeight(.heavy)
            .textCase(nil)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
    }
}

#Preview {
    HeaderView {
        Text("Title")
    }
}
