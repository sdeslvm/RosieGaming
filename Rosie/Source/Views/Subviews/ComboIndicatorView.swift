//
//  ComboIndicatorView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

struct ComboIndicatorView: View {
    @Binding var multiplier: Double
    @Binding var timeRemaining: Double
    @Binding var isActive: Bool
    
    // Animation properties
    @State private var pulsate = false
    
    var body: some View {
        VStack(spacing: 2) {
            // Combo multiplier text
            Text("COMBO x\(String(format: "%.1f", multiplier))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(multiplierColor)
                .scaleEffect(pulsate ? 1.1 : 1.0)
                .opacity(isActive ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: isActive)
                .animation(.easeInOut(duration: 0.2).repeatCount(3, autoreverses: true), value: pulsate)
            
            // Timer bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(.black.opacity(0.2))
                    
                    // Progress
                    Capsule()
                        .fill(timerColor)
                        .frame(width: max(0, min(geometry.size.width * CGFloat(timeRemaining / 3.0), geometry.size.width)))
                }
            }
            .frame(height: 8)
            .opacity(isActive ? 1.0 : 0.0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: multiplierColor.opacity(0.6), radius: isActive ? 5 : 0)
        )
        .onChange(of: multiplier) { newValue in
            if newValue > 1.0 {
                withAnimation {
                    pulsate = true
                }
                
                // Reset pulsation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        pulsate = false
                    }
                }
            }
        }
    }
    
    // Color based on multiplier value
    private var multiplierColor: Color {
        if multiplier >= 2.5 {
            return .red
        } else if multiplier >= 2.0 {
            return .orange
        } else if multiplier >= 1.5 {
            return .yellow
        } else {
            return .black.opacity(0.5)
        }
    }
    
    // Color for the timer bar
    private var timerColor: Color {
        let ratio = timeRemaining / 3.0
        if ratio < 0.3 {
            return .red
        } else if ratio < 0.6 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    ComboIndicatorView(multiplier: .constant(1), timeRemaining: .constant(15.0), isActive: .constant(true))
        .padding(.horizontal, 100)
}
