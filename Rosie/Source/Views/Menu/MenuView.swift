//
//  MenuView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

struct MenuView: View {
    // MARK: - Properties
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var settings = SettingsManager.shared
    
    @State private var showClassicMode = false
    @State private var showSpeedMode = false
    @State private var showAchievements = false
    @State private var showShop = false
    @State private var showSettings = false
    @State private var showRules = false
    @State private var showVortex = false
    
    @State private var buttonScale: CGFloat = 1.0
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(.bgimg)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // Title
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 170)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Classic mode button
                        gameButton(title: "CLASSIC MODE") {
                            showClassicMode = true
                        }
                        
                        gameButton(title: "VORTEX") {
                            showVortex = true
                        }
                        
                        // Speed mode button
                        gameButton(title: "SPEED MODE") {
                            showSpeedMode = true
                        }
                        
                        // Achi button
                        gameButton(title: "ACHIEVEMENTS") {
                            showAchievements = true
                        }
                        
                        // Shop button
                        gameButton(title: "SHOP") {
                            showShop = true
                        }
                        
                        // Settings button
                        gameButton(title: "SETTINGS") {
                            showSettings = true
                        }
                        
                        // RULES button
                        gameButton(title: "RULES") {
                            showRules = true
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                
                // Navigation links
                navigationLinks
            }
            .onAppear {
                if settings.isMusicOn {
                    settings.playMusic()
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            settings.playMusic()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                settings.playMusic()
            case .background, .inactive:
                settings.stopMusic()
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - UI Components
    
    private func gameButton(title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(.ellipse)
                .resizable()
                .frame(width: 250, height: 50)
                .overlay {
                    Text(title)
                        .myfont2(26)
                }
        }
        .scaleEffect(buttonScale)
        .animation(.spring(), value: buttonScale)
    }
    
    private var navigationLinks: some View {
        Group {
            // GameView classic
            NavigationLink(
                destination: GameView(gameMode: .classic),
                isActive: $showClassicMode,
                label: { EmptyView() }
            )
            
            NavigationLink(
                destination: GamesLevels(),
                isActive: $showVortex,
                label: { EmptyView() }
            )
        
            
            // GameView speed mode
            NavigationLink(
                destination: GameView(gameMode: .speedMode),
                isActive: $showSpeedMode,
                label: { EmptyView() }
            )
            
            // AchievementsView
            NavigationLink(
                destination: AchiView(),
                isActive: $showAchievements,
                label: { EmptyView() }
            )
            
            // ShopView
            NavigationLink(
                destination: ShopView(),
                isActive: $showShop,
                label: { EmptyView() }
            )
            
            // SettingsView
            NavigationLink(
                destination: SettingsView(),
                isActive: $showSettings,
                label: { EmptyView() }
            )
            
            // RulesView
            NavigationLink(
                destination: RulesView(),
                isActive: $showRules,
                label: { EmptyView() }
            )
        }
    }
}

#Preview {
    MenuView()
}
