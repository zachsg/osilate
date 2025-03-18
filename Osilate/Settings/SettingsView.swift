//
//  SettingsView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                UserSection()
                
                MoveSection()
                
                SweatSection()
                
                BreatheSection()
                
                Section {
                    // Left empty intentionally
                } footer: {
                    Text("Note: Weekly goals for Move, Sweat, Breathe are auto-calculated based on your daily goals.")
                }
                
                AppDetailsSection()
            }
            .navigationTitle(settingsString)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
