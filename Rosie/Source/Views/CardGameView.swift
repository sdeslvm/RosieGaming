import SwiftUI

struct CardGameView: View {
    @State private var cards: [Card] = []
    @State private var selectedCards: [Card] = []
    @State private var isAnimating = false
    @State private var isGameFinished = false // Флаг завершения игры
    @Environment(\.dismiss) private var dismiss
    
    private let cardImages = ["firstCard", "secondCard", "thirdCard", "fourCard", "fiveCard", "sixCard"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                VStack {
                    Image(.findCup)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 70)
                        .padding()
                    Spacer()
                }
                
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
                
                // Основной контент
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 20) {
                    ForEach(cards) { card in
                        CardView(card: card)
                            .onTapGesture {
                                handleCardTap(card)
                            }
                    }
                }
                .padding()
                .padding(.top, 120)
                
                // WinView отображается поверх всего, если игра завершена
                if isGameFinished {
                    Color.black.opacity(0.8) // Полупрозрачный фон
                        .edgesIgnoringSafeArea(.all)
                    
                    WinView1()
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.8)
                        .transition(.opacity) // Анимация появления
                        .onTapGesture {
                            dismiss()
                        }
                }
            }
            .navigationBarHidden(true)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.backgroundGame)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.02)
            )
        }
        .onAppear {
            startNewGame()
        }
    }
    
    private func startNewGame() {
        // Создаем пары карт
        var tempCards = cardImages.flatMap { image in
            [Card(id: UUID(), imageName: image, isFaceUp: false),
             Card(id: UUID(), imageName: image, isFaceUp: false)]
        }
        
        // Перемешиваем карты
        tempCards.shuffle()
        
        cards = tempCards
        selectedCards = []
        isGameFinished = false // Сбрасываем флаг завершения игры
    }
    
    private func handleCardTap(_ card: Card) {
        guard !isAnimating else { return }
        
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            var newCards = cards
            newCards[index].isFaceUp = true
            cards = newCards
            
            if selectedCards.count < 2 {
                selectedCards.append(card)
                
                if selectedCards.count == 2 {
                    isAnimating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if selectedCards[0].imageName == selectedCards[1].imageName {
                            // Совпадение найдено - оставляем карты открытыми
                            selectedCards = []
                            isAnimating = false
                        } else {
                            // Нет совпадения - переворачиваем карты обратно
                            var newCards = cards
                            if let index1 = newCards.firstIndex(where: { $0.id == selectedCards[0].id }) {
                                newCards[index1].isFaceUp = false
                            }
                            if let index2 = newCards.firstIndex(where: { $0.id == selectedCards[1].id }) {
                                newCards[index2].isFaceUp = false
                            }
                            cards = newCards
                            selectedCards = []
                            isAnimating = false
                        }
                        
                        // Проверяем, завершена ли игра
                        checkIfGameFinished()
                    }
                }
            }
        }
    }
    
    private func checkIfGameFinished() {
        // Игра завершена, если все карты открыты
        if cards.allSatisfy({ $0.isFaceUp }) {
            isGameFinished = true
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            if card.isFaceUp {
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotation3DEffect(.degrees(0), axis: (x: 0, y: 1, z: 0))
            } else {
                Image("cardBack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .frame(width: 100, height: 140)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct Card: Identifiable {
    let id: UUID
    let imageName: String
    var isFaceUp: Bool
}

struct WinView1: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("winView")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.22)
            }
        }
    }
}

#Preview {
    CardGameView()
}
