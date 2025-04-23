//
//  PhysicsCategory.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let ball: UInt32 = 0x1
    static let wall: UInt32 = 0x1 << 1
    static let boundary: UInt32 = 0x1 << 2
}
