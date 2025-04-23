//
//  LeaderboardView.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

struct LeaderboardView: View {
    // MARK: - Properties
    
    @Binding var isShowing: Bool
    let playerScore: Int
    let gameMode: GameMode
    
    @State private var leaderboardEntries: [LeaderboardEntry] = []
    
    // Computed player rank
    private var playerRank: Int {
        // Get current high score
        let highScore = UserDefaults.standard.integer(forKey: gameMode.leadersKey)
        let scoreToCompare = max(playerScore, highScore)
        
        // Find player rank by comparing with leaderboard entries
        var rank = 1
        for entry in leaderboardEntries {
            if entry.score > scoreToCompare {
                rank += 1
            }
        }
        
        return rank
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isShowing = false }
                }
            
            VStack(spacing: 15) {
                HStack {
                    // Close button
                    Button {
                        withAnimation { isShowing = false }
                    } label: {
                        Image(.back)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
                .padding(.leading)
                
                // Header
                VStack(spacing: 5) {
                    Text("LEADERBOARD")
                        .myfont2(28)
                    
                    // Mode indicator
                    Text(gameMode.title)
                        .myfont2(16)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.4))
                        )
                }
                
                // Divider
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal)
                
                // List headers
                HStack {
                    Text("Rank")
                        .frame(width: 50, alignment: .leading)
                    
                    Text("Player")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Score")
                        .frame(width: 80, alignment: .trailing)
                }
                .font(.system(size: 14, weight: .bold, design: .serif))
                .foregroundStyle(.gray)
                .padding(.horizontal, 20)
                
                // List of top players
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(leaderboardEntries) { entry in
                            HStack {
                                Text("#\(entry.rank)")
                                    .frame(width: 50, alignment: .leading)
                                
                                Text(entry.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                
                                Text("\(entry.score)")
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 350)
                
                // Divider
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal)
                
                // Player's position
                HStack {
                    Text("#\(playerRank)")
                        .frame(width: 50, alignment: .leading)
                    
                    Text("You")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(UserDefaults.standard.integer(forKey: gameMode.leadersKey))")
                        .frame(width: 80, alignment: .trailing)
                }
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(.yellow)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(
                    Capsule()
                        .fill(.yellow.opacity(0.1))
                )
                .padding(.horizontal)
                
            }
            .frame(maxWidth: 350)
//            .padding(.horizontal)
            .onAppear(perform: loadLeaderboardData)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadLeaderboardData() {
        switch gameMode {
        case .classic:
            leaderboardEntries = [
                LeaderboardEntry(rank: 1, name: "Champion", score: 150000),
                LeaderboardEntry(rank: 2, name: "Master", score: 100000),
                LeaderboardEntry(rank: 3, name: "Expert", score: 95000),
                LeaderboardEntry(rank: 4, name: "Pro", score: 80000),
                LeaderboardEntry(rank: 5, name: "Veteran", score: 65000),
                LeaderboardEntry(rank: 6, name: "Advanced", score: 55000),
                LeaderboardEntry(rank: 7, name: "Skilled", score: 40000),
                LeaderboardEntry(rank: 8, name: "Amateur", score: 30000),
                LeaderboardEntry(rank: 9, name: "Beginner", score: 25000),
                LeaderboardEntry(rank: 10, name: "Novice", score: 15000)
            ]
        case .speedMode:
            leaderboardEntries = [
                LeaderboardEntry(rank: 1, name: "Speedster", score: 100000),
                LeaderboardEntry(rank: 2, name: "Quicksilver", score: 85000),
                LeaderboardEntry(rank: 3, name: "Lightning", score: 65000),
                LeaderboardEntry(rank: 4, name: "Swift", score: 58000),
                LeaderboardEntry(rank: 5, name: "Rapid", score: 50000),
                LeaderboardEntry(rank: 6, name: "Fast", score: 45000),
                LeaderboardEntry(rank: 7, name: "Nimble", score: 40000),
                LeaderboardEntry(rank: 8, name: "Quick", score: 35000),
                LeaderboardEntry(rank: 9, name: "Speedy", score: 30000),
                LeaderboardEntry(rank: 10, name: "Hasty", score: 25000)
            ]
        }
        
        // Later this would be implemented to load from a JSON file:
        // if let path = Bundle.main.path(forResource: "\(gameMode.leadersKey)", ofType: "json") {
        //     do {
        //         let data = try Data(contentsOf: URL(fileURLWithPath: path))
        //         leaderboardEntries = try JSONDecoder().decode([LeaderboardEntry].self, from: data)
        //     } catch {
        //         print("Error loading leaderboard data: \(error)")
        //     }
        // }
    }
}

#Preview {
    LeaderboardView(isShowing: .constant(true), playerScore: 125, gameMode: GameMode.classic)
}
