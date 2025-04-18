//
//  MirroringSheet.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/15/25.
//

import SwiftUI

struct MirroringSheet: View {
    @Environment(HealthController.self) private var healthController
    
    @Binding var sheetIsShowing: Bool
    
    var isOutdoors: Bool {
        let locationType = healthController.mirroredSession?.workoutConfiguration.locationType;
        
        switch locationType {
        case .unknown, .indoor:
            return false
        case .outdoor:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                ZonesView()
                    .toolbar {
                        ToolbarItem {
                            Button {
                                healthController.isMirroring = false
                                sheetIsShowing.toggle()
                            } label: {
                                Label {
                                    Text(closeLabel)
                                } icon: {
                                    Image(systemName: cancelSystemImage)
                                }
                            }
                        }
                    }
                    .tabItem {
                        Label("HR Zones", systemImage: "heart.fill")
                    }.tag(1)
                
                if !isOutdoors {
                    MapView()
                        .tabItem {
                            Label("Map", systemImage: "map")
                        }.tag(2)
                }
            }
            .navigationTitle("Mirroring")
            .navigationBarTitleDisplayMode(.inline)
        }
        .unlockRotation()
    }
}

#Preview {
    MirroringSheet(sheetIsShowing: .constant(true))
        .environment(HealthController())
}
