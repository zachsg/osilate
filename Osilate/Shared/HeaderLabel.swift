//
//  HeaderLabel.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/9/25.
//

import SwiftUI

struct HeaderLabel: View {
    let title: String
    let systemImage: String
    var color: Color = .accentColor
    
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote.bold())
            .foregroundStyle(color)
    }
}

#Preview {
    HeaderLabel(title: "Progress", systemImage: streaksSystemImage)
}
