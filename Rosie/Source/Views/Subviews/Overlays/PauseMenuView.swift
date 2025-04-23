//
//  PauseMenuView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

import SwiftUI

struct PauseMenuView: View {
    // MARK: - Properties
    
    @StateObject private var settings = SettingsManager.shared
    
    @Binding var isShowing: Bool
    let resumeAction: () -> Void
    let restartAction: () -> Void
    let returnToMenuAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { resumeAction() }
                }
            
            VStack(spacing: 15) {
                HStack {
                    // Resume button
                    Button {
                        withAnimation { resumeAction() }
                    } label: {
                        Image(.back)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
                .padding(.leading)
                
                // Header
                Text("PAUSE")
                    .myfont2(28)
                
                // Sound and music toggles
                VStack(spacing: 5) {
                    // Sound toggle
                    ToggleButtonView(name: "SOUND", isOn: settings.isSoundOn) {
                        settings.toggleSound()
                    }
                    
                    // Music toggle
                    ToggleButtonView(name: "MUSIC", isOn: settings.isMusicOn) {
                        settings.toggleMusic()
                    }
                    
                    // Vibro toggle
                    ToggleButtonView(name: "VIBRO", isOn: settings.isVibroOn) {
                        settings.toggleVibro()
                    }
                }
                
                // Buttons
                VStack(spacing: 20) {
                    Button {
                        restartAction()
                    } label: {
                        Image(.ellipse)
                            .resizable()
                            .frame(width: 200, height: 50)
                            .overlay {
                                Text("RESTART")
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
        }
    }
}

#Preview {
    PauseMenuView(isShowing: .constant(true), resumeAction: {}, restartAction: {}, returnToMenuAction: {})
}
