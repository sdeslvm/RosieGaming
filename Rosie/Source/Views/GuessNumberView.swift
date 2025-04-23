import SwiftUI
import UIKit

struct GuessNumberView: View {
    @State private var targetNumber = Int.random(in: 1...999)
    @State private var currentNumber = ""
    @State private var currentDigits: [String] = ["", "", ""]
    @State private var hint: String?
    @State private var showHint = false
    @State private var isGameOver = false
    @Environment(\.dismiss) private var dismiss
    
    private let numberImages = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
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
                    Image(.guessnum)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 70)
                        .padding()
                    Spacer()
                }
                
                if isGameOver {
                    // Проверяем, победил ли игрок
                    if hint == "Победа!" {
                        WinView1()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.8)
                            .transition(.opacity) // Анимация появления
                            .onTapGesture {
                                dismiss()
                            }                    } else {
                        // Если проиграл, отображаем изображение подсказки
                        Image(hint == "Меньше" ? "guesshigh" : "guessLow")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                resetGame()
                            }
                    }
                } else {
                    VStack(spacing: 20) {
                        HStack(spacing: 10) {
                            ForEach(0..<3) { index in
                                NumberBlockView(digit: currentDigits[index])
                            }
                        }
                        
                        LazyVGrid(
                            columns: Array(repeating: GridItem(spacing: isPad ? -450 : 0), count: 3), // Установите
                            spacing: 20 // Установите spacing для строк
                        ) {
                            ForEach(numberImages, id: \.self) { number in
                                NumberButtonView(number: number)
                                    .onTapGesture {
                                        handleNumberTap(number)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image("backgroundGame")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
        }
    }
    
    private func handleNumberTap(_ number: String) {
        guard currentDigits.filter { !$0.isEmpty }.count < 3 else { return }
        
        if let index = currentDigits.firstIndex(where: { $0.isEmpty }) {
            currentDigits[index] = number
            
            if currentDigits.allSatisfy({ !$0.isEmpty }) {
                let guessedNumber = Int(currentDigits.joined()) ?? 0
                checkGuess(guessedNumber)
            }
        }
    }
    
    private func checkGuess(_ guessedNumber: Int) {
        if guessedNumber == targetNumber {
            hint = "Победа!"
            isGameOver = true
        } else {
            hint = guessedNumber < targetNumber ? "Меньше" : "Больше"
            isGameOver = true
        }
    }
    
    private func resetGame() {
        targetNumber = Int.random(in: 1...999)
        currentNumber = ""
        currentDigits = ["", "", ""]
        hint = nil
        showHint = false
        isGameOver = false
    }
}

struct NumberBlockView: View {
    let digit: String
    
    var body: some View {
        ZStack {
            Image("blockNumber")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            if !digit.isEmpty {
                Text(digit)
                    .font(.system(size: 30))
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .frame(width: 80, height: 80)
    }
}

struct NumberButtonView: View {
    let number: String
    
    var body: some View {
        Image(number)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}



#Preview {
    GuessNumberView()
}
