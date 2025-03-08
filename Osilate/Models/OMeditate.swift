//
//  OMeditate.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import SwiftData
import Foundation

@Model
class OMeditate: OActivity {
//    #Unique<PMeditate>([\.id])
//    #Index<PMeditate>([\.id, \.date])
    
    var id = UUID()
    var date: Date = Date.now
    var duration: Int = 0
    
    init(id: UUID = UUID(), date: Date, duration: Int) {
        self.id = id
        self.date = date
        self.duration = duration
    }
}
