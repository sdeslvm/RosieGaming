//
//  Achievement.swift
//  Rosie
//
//  Created by Alex on 31.03.2025.
//

import Foundation

enum Achievement: Int, CaseIterable, Identifiable {
    case firstbud = 0
    case flowermaster
    case explosionofcolors
    case endlessbloom
    case legendarygarden
    case ohwhatwasbeautiful
    case gardeningexpert
    case floralfortune
    case perfectstreak
    case fastandbeautiful
    case floralspeedrunner
    case combomaster
    case masterofthegarden
    
    var id: Int { self.rawValue }
    
    var imageName: String {
        switch self {
        case .firstbud:
            return "firstbud"
        case .flowermaster:
            return "flowermaster"
        case .explosionofcolors:
            return "explosionofcolors"
        case .endlessbloom:
            return "endlessbloom"
        case .legendarygarden:
            return "legendarygarden"
        case .ohwhatwasbeautiful:
            return "ohwhatwasbeautiful"
        case .gardeningexpert:
            return "gardeningexpert"
        case .floralfortune:
            return "floralfortune"
        case .perfectstreak:
            return "perfectstreak"
        case .fastandbeautiful:
            return "fastandbeautiful"
        case .floralspeedrunner:
            return "floralspeedrunner"
        case .combomaster:
            return "combomaster"
        case .masterofthegarden:
            return "masterofthegarden"
        }
    }
}
