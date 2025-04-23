//
//  Leaderboard.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import Foundation

struct LeaderboardEntry: Identifiable, Codable {
    var id = UUID()
    let rank: Int
    let name: String
    let score: Int
}
