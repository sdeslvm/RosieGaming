import SwiftUI

struct GamesLevels: View {
    // MARK: - Properties
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var settings = SettingsManager.shared
    
    @State private var showGuessNum = false
    @State private var showCardGame = false
    @State private var showSpeedCard = false
    @State private var showLab = false
//    @State private var showLabyrinth = false
    
    @State private var buttonScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(.bgimg)
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // Header with back button
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(.back)
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .padding()
                        
                        Spacer()
                        
                    }
                    Spacer()
                }
                
                VStack {
                    // Title
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 170)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        // Classic mode button
                        gameButton(title: "GUESS NUM") {
                            showGuessNum = true
                        }
                        
                        gameButton(title: "CARD GAME") {
                            showCardGame = true
                        }
                        
                        gameButton(title: "SPEED CARD") {
                            showSpeedCard = true
                        }
                        
                        gameButton(title: "LABYRINTH") {
                            showLab = true
                        }
                        
//                        gameButton(title: "LABYRINTH") {
//                            showSpeedMode = true
//                        }
                        

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
        .navigationBarHidden(true)
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
            NavigationLink(
                destination: GuessNumberView(),
                isActive: $showGuessNum,
                label: { EmptyView() }
            )
            
            NavigationLink(
                destination: CardGameView(),
                isActive: $showCardGame,
                label: { EmptyView() }
            )
            
            NavigationLink(
                destination: RememberNumbers(),
                isActive: $showSpeedCard,
                label: { EmptyView() }
            )
            
            NavigationLink(
                destination: LabView(),
                isActive: $showLab,
                label: { EmptyView() }
            )
            
        
//            NavigationLink(
//                destination: RememberNumbers(),
//                isActive: $showLabyrinth,
//                label: { EmptyView() }
//            )
        }
    }
}

#Preview {
    GamesLevels()
}
