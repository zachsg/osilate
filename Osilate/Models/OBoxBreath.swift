//
//  OBoxBreath.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftData

@Model
class OBoxBreath: OActivity {
//    #Unique<PBoxBreath>([\.id])
//    #Index<PBoxBreath>([\.id, \.date])
    
    var id = UUID()
    var date: Date = Date.now
    var duration: Int = 0
    var rounds: Int = 20
    
    init(id: UUID = UUID(), date: Date, duration: Int, rounds: Int) {
        self.id = id
        self.date = date
        self.duration = duration
        self.rounds = rounds
    }
}
