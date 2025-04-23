//
//  AppStateManager.swift
//  Rosie
//
//  Created by Alex on 31.03.2025.
//

import Foundation

@MainActor
final class AppStateManager: ObservableObject {
    @Published private(set) var appState: AppState = .loading
    let webManager: NetworkManager
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func stateCheck() {
        Task {
            if webManager.targetURL != nil {
                appState = .webView
                return
            }
            
            do {
                if try await webManager.checkInitialURL() {
                    appState = .webView
                } else {
                    appState = .mainMenu
                }
            } catch {
                appState = .mainMenu
            }
        }
    }
    
    enum AppState {
        case loading
        case webView
        case mainMenu
    }
}
