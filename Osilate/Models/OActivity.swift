//
//  OActivity.swift
//  Osilate
//
//  Created by Zach Gottlieb on 3/7/25.
//

import Foundation
import SwiftData

protocol OActivity: Identifiable, PersistentModel {
    var id: UUID { get }
    var date: Date { get set }
}
