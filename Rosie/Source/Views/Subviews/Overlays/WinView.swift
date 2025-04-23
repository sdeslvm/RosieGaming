//
//  WinView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

struct WinView: View {
    // MARK: - Properties
    
    @Binding var isShowing: Bool
    let score: Int
    let gameMode: GameMode
    let nextLevelAction: () -> Void
    let returnToMenuAction: () -> Void
    
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    @ObservedObject private var shopManager = ShopManager.shared
    @State private var showCurrencyAnimation: Bool = false
    @State private var rewardAmount: Int = 100
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                ZStack {
                    Text(winTitle)
                        .myfont2(28)
                        .colorMultiply(.yellow)
                        .shadow(color: .yellow, radius: 10, x: 1, y: 1)
                }
                
                HStack(spacing: 15) {
                    VStack(spacing: 0) {
                        Image(.coin)
                            .resizable()
                            .frame(width: 100, height: 100)
                        
                        Text("+\(rewardAmount)")
                            .myfont2(18)
                            .colorMultiply(.yellow)
                            .scaleEffect(showCurrencyAnimation ? 1.5 : 1)
                            .opacity(showCurrencyAnimation ? 0.8 : 1)
                            .animation(
                                Animation.spring(response: 0.5, dampingFraction: 0.6)
                                    .repeatCount(3, autoreverses: true),
                                value: showCurrencyAnimation
                            )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Score:")
                            .myfont(22)
                        Text("\(score)")
                            .myfont2(22)
                    }
                }
                
                // Кнопки
                VStack(spacing: 20) {
                    Button {
                        nextLevelAction()
                    } label: {
                        Image(.ellipse)
                            .resizable()
                            .frame(width: 200, height: 50)
                            .overlay {
                                Text("CONTINUE")
                                    .myfont2(26)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        returnToMenuAction()
                    } label: {
                        Image(.ellipse)
                            .resizable()
                            .frame(width: 200, height: 50)
                            .overlay {
                                Text("MENU")
                                    .myfont2(26)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: 350)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                let highScore = UserDefaults.standard.integer(forKey: gameMode.leadersKey)
                if score > highScore {
                    UserDefaults.standard.set(score, forKey: gameMode.leadersKey)
                }
                
                calculateReward()
                shopManager.addCurrency(amount: rewardAmount)
                
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 1
                    scale = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCurrencyAnimation = true
                }
            }
        }
    }
    
    // MARK: - Computed properties
    
    private var winTitle: String {
        switch gameMode {
        case .classic:
            return "VICTORY!"
        case .speedMode:
            return "TIME'S UP!"
        }
    }
    
    // MARK: - Methods
    
    private func calculateReward() {
        switch gameMode {
        case .classic:
            rewardAmount = 100
            
            if score > 100_000 {
                rewardAmount += 50
            }
            if score > 50_000 {
                rewardAmount += 20
            }
            
        case .speedMode:
            rewardAmount = score / 1000
            if rewardAmount < 20 {
                rewardAmount = 20 // min reward
            } else if rewardAmount > 200 {
                rewardAmount = 200 // max reward
            }
        }
    }
}

#Preview {
    WinView(isShowing: .constant(true), score: 99999, gameMode: GameMode.speedMode, nextLevelAction: {}, returnToMenuAction: {})
}
