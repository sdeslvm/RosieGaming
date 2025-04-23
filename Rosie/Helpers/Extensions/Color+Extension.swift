//
//  Color+Extension.swift
//  Rosie
//
//  Created by Alex on 29.03.2025.
//

import SwiftUI

extension Color {
    static let gradientBlueWhite = LinearGradient(
        gradient: Gradient(colors: [.white, .cyan, .cyan, .cyan, .blue]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let rainbowGradient = LinearGradient(
        gradient: Gradient(colors: [.cyan.opacity(0.5), .cyan, .green.opacity(0.5), .purple.opacity(0.5), .purple, .blue.opacity(0.5), .blue, .orange.opacity(0.5), .orange]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
