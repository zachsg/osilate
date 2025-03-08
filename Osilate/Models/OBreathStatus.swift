//
//  OBreathStatus.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation

enum OBreathStatus: String, Codable, CaseIterable {
    case inhale,
         exhale,
         holdInhale = "hold inhale",
         holdExhale = "hold exhale"
}
