//
//  SampleData.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftUI
import SwiftData

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let schema = Schema([
            OMeditate.self,
            O478Breath.self,
            OBoxBreath.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        let meditate = OMeditate(date: .now, duration: 300)
        let four78 = O478Breath(date: .now.addingTimeInterval(-7200), duration: 200, rounds: 8)
        let box = OBoxBreath(date: .now.addingTimeInterval(-10800), duration: 600, rounds: 40)
        container.mainContext.insert(meditate)
        container.mainContext.insert(four78)
        container.mainContext.insert(box)
        
        let meditateOld = OMeditate(date: .now.addingTimeInterval(-86400), duration: 300)
        let four78Old = O478Breath(date: .now.addingTimeInterval(-93600), duration: 200, rounds: 8)
        let boxOld = OBoxBreath(date: .now.addingTimeInterval(-172800), duration: 600, rounds: 40)
        container.mainContext.insert(meditateOld)
        container.mainContext.insert(four78Old)
        container.mainContext.insert(boxOld)
        
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}
