//
//  OsilateApp.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftUI
import SwiftData

@main
struct OsilateApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var healthController = HealthController()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            OMeditate.self,
            O478Breath.self,
            OBoxBreath.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(healthController)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                healthController.startMirroring() // Re-establish mirroring when app becomes active
            case .background:
                break // Handle background state if needed
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
