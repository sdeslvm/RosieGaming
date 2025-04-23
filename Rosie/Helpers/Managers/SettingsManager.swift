//
//  SettingsManager.swift
//  Rosie
//
//  Created by Alex on 30.03.2025.
//

import AVFoundation
import SwiftUI
import StoreKit

@MainActor
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var isSoundOn: Bool {
        didSet { defaults.set(isSoundOn, forKey: "soundOn") }
    }
    
    @Published var isMusicOn: Bool {
        didSet {
            defaults.set(isMusicOn, forKey: "musicOn")
            isMusicOn ? playMusic() : stopMusic()
        }
    }
    
    @Published var isVibroOn: Bool {
        didSet { defaults.set(isVibroOn, forKey: "vibroOn") }
    }
    
    private let defaults = UserDefaults.standard
    private var audioPlayer: AVAudioPlayer?
    private var clickPlayer: AVAudioPlayer?
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        self.isSoundOn = true
        self.isMusicOn = true
        self.isVibroOn = true
        
        if defaults.object(forKey: "soundOn") != nil {
            self.isSoundOn = defaults.bool(forKey: "soundOn")
        } else {
            defaults.set(true, forKey: "soundOn")
        }
        
        if defaults.object(forKey: "musicOn") != nil {
            self.isMusicOn = defaults.bool(forKey: "musicOn")
        } else {
            defaults.set(true, forKey: "musicOn")
        }
        
        if defaults.object(forKey: "vibroOn") != nil {
            self.isVibroOn = defaults.bool(forKey: "vibroOn")
        } else {
            defaults.set(true, forKey: "vibroOn")
        }
        
        setupAudioSession()
        prepareMusic()
        prepareSound()
    }
    
    // MARK: - Sound & Music
    func toggleSound() { isSoundOn.toggle() }
    func toggleMusic() { isMusicOn.toggle() }
    
    func playSound() {
        guard isSoundOn, let player = clickPlayer, !player.isPlaying else { return }
        player.play()
    }
    
    func playMusic() {
        guard isMusicOn, let player = audioPlayer, !player.isPlaying else { return }
        player.play()
    }
    
    func stopMusic() {
        audioPlayer?.pause()
    }
    
    // MARK: - Vibration
    func toggleVibro() { isVibroOn.toggle() }
    
    func vibrateLight() {
        guard isVibroOn else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func vibrateSuccess() {
        guard isVibroOn else { return }
        notificationFeedbackGenerator.notificationOccurred(.success)
    }
    
    func vibrateError() {
        guard isVibroOn else { return }
        notificationFeedbackGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Rate App
    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func openAppStoreForRating() {
        let appID = "6744023808"
        let urlString = "https://apps.apple.com/app/id\(appID)?action=write-review"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Private Methods
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    private func prepareMusic() {
        guard let url = Bundle.main.url(forResource: "music", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func prepareSound() {
        guard let url = Bundle.main.url(forResource: "sound", withExtension: "mp3") else { return }
        do {
            clickPlayer = try AVAudioPlayer(contentsOf: url)
            clickPlayer?.prepareToPlay()
        } catch {
            print(error.localizedDescription)
        }
    }
}
