//
//  OZone.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/17/25.
//

import Foundation

enum OZone: String, Codable, CaseIterable, Comparable {
   case zero = "0", one = "1", two = "2", three = "3", four = "4", five = "5"
    
    static func < (lhs: OZone, rhs: OZone) -> Bool {
        let order: [OZone] = [.zero, .one, .two, .three, .four, .five]
        
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        
        return lhsIndex < rhsIndex
    }
}

enum OZoneStartEnd: String, Codable, CaseIterable {
    case start, end
}
