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
    
    var body: some View {
        NavigationStack {
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
                .navigationTitle("Mirroring")
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Keep screen on
            UIApplication.shared.isIdleTimerDisabled = true
            
            // Allow landscape orientations
            UIApplication.shared.updateOrientation([.portrait, .landscapeLeft, .landscapeRight])
        }
        .onDisappear {
            // Restore auto-lock
            UIApplication.shared.isIdleTimerDisabled = false
            
            // Restrict to portrait
            UIApplication.shared.updateOrientation(.portrait)
        }
    }
}

#Preview {
    MirroringSheet(sheetIsShowing: .constant(true))
        .environment(HealthController())
}
