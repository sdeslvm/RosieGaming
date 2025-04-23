//
//  SettingsView.swift
//  Rosie
//
//  Created by Alex on 30.03.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        ZStack {
            Image(.bgimg)
                .resizable()
                .ignoresSafeArea()
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(.back)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
                
                Spacer()
                
                // Header
                Text("SETTINGS")
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
                Button {
                    settings.requestReview()
                } label: {
                    Image(.ellipse)
                        .resizable()
                        .frame(width: 200, height: 50)
                        .overlay {
                            Text("RATE US")
                                .myfont2(26)
                        }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    SettingsView()
}
