//
//  AppDetailsSection.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/8/25.
//

import SwiftUI

struct AppDetailsSection: View {
    var appVersion: String {
        UIApplication.appVersion ?? "Unknown"
    }
    
    var body: some View {
        Section {
            // Add any dev info about the app
        } header: {
            HStack {
                Spacer()
                Text("App: \(appVersion)")
                Spacer()
            }
        }
    }
}

#Preview {
    AppDetailsSection()
}
