//
//  NetworkManager.swift
//  Rosie
//
//  Created by Alex on 31.03.2025.
//

import UIKit
import SwiftUI

class NetworkManager: ObservableObject {
    
    @Published private(set) var targetURL: URL?
    static let initialURL = URL(string: "https://rosiegaming.top/install")!
    private let storage: UserDefaults
    private var didSaveURL = false
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadProvenURL()
    }
    
    func checkURL(_ url: URL) {
        if didSaveURL {
            return
        }
        
        guard !isInvalidURL(url) else {
            return
        }
        
        storage.set(url.absoluteString, forKey: "savedurl")
        targetURL = url
        didSaveURL = true
    }
    
    private func loadProvenURL() {
        if let urlString = storage.string(forKey: "savedurl") {
            if let url = URL(string: urlString) {
                targetURL = url
                didSaveURL = true
            } else {
                print("Error: load - \(urlString)")
            }
        }
    }
    
    private func isInvalidURL(_ url: URL) -> Bool {
        let invalidURLs = ["about:blank", "about:srcdoc"]
        
        if invalidURLs.contains(url.absoluteString) {
            return true
        }
        
        return false
    }
    
    func checkInitialURL() async throws -> Bool {
        do {
            var request = URLRequest(url: Self.initialURL)
            request.setValue(getUAgent(forWebView: false), forHTTPHeaderField: "User-Agent")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return true
            }
            
            if (400...599).contains(httpResponse.statusCode) {
                return false
            }
            
            return true

        } catch {
            return false
        }
    }
    
    func getUAgent(forWebView: Bool = false) -> String {
        if forWebView {
            let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            let agent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            return agent
        } else {
            let agent = "TestRequest/1.0 CFNetwork/1410.0.3 Darwin/22.4.0"
            return agent
        }
    }
}
