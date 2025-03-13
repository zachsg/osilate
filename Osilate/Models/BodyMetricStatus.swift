//
//  BodyMetricStatus.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/13/25.
//

import Foundation

enum BodyMetricStatus: String, Codable, CaseIterable {
    case low, normal, high, optimal, missing
}
