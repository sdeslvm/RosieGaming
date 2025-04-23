//
//  BallType.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import Foundation
import UIKit

enum BallType: Int, CaseIterable {
    case smallest = 0
    case small
    case mediumSmall
    case medium
    case mediumLarge
    case large
    case larger
    case evenLarger
    case almostLargest
    case largest
    
    // Returns the next ball type in the evolution chain
    func next() -> BallType {
        let nextRawValue = self.rawValue + 1
        if nextRawValue < BallType.allCases.count {
            return BallType(rawValue: nextRawValue) ?? .largest
        }
        return .largest
    }
    
    // Diameter for this ball type
    var size: CGFloat {
        switch self {
        case .smallest:
            return 30
        case .small:
            return 40
        case .mediumSmall:
            return 50
        case .medium:
            return 60
        case .mediumLarge:
            return 70
        case .large:
            return 80
        case .larger:
            return 90
        case .evenLarger:
            return 100
        case .almostLargest:
            return 110
        case .largest:
            return 120
        }
    }
    
    // Image name for this ball type
    var imageName: String {
        switch self {
        case .smallest:
            return "smallest"
        case .small:
            return "small"
        case .mediumSmall:
            return "mediumSmall"
        case .medium:
            return "medium"
        case .mediumLarge:
            return "mediumLarge"
        case .large:
            return "large"
        case .larger:
            return "larger"
        case .evenLarger:
            return "evenLarger"
        case .almostLargest:
            return "almostLargest"
        case .largest:
            return "largest"
        }
    }
    
    // Points awarded for creating this ball
    var points: Int {
        return (self.rawValue + 1) * 10
    }
}
