//
//  Item.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
