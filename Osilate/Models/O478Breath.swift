//
//  O478Breath.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftData

@Model
class O478Breath: OActivity {
//    #Unique<P478Breath>([\.id])
//    #Index<P478Breath>([\.id, \.date])
    
    var id = UUID()
    var date: Date = Date.now
    var duration: Int = 0
    var rounds: Int = 6
    
    init(id: UUID = UUID(), date: Date, duration: Int, rounds: Int) {
        self.id = id
        self.date = date
        self.duration = duration
        self.rounds = rounds
    }
}
