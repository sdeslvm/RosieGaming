//
//  GameMode.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import Foundation

enum GameMode {
    case classic
    case speedMode
    
    var title: String {
        switch self {
        case .classic:
            return "Classic"
        case .speedMode:
            return "Speed Mode"
        }
    }
    
    var description: String {
        switch self {
        case .classic:
            return "Merge balls and create the largest one without overflowing"
        case .speedMode:
            return "Score as many points as possible in 30 seconds"
        }
    }
    
    var timerDuration: TimeInterval? {
        switch self {
        case .classic:
            return nil
        case .speedMode:
            return 30.0
        }
    }
    
    var leadersKey: String {
        switch self {
        case .classic:
            return "highScore"
        case .speedMode:
            return "speedModeHighScore"
        }
    }
}
