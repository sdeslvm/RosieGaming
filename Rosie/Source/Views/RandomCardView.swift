import SwiftUI

struct RememberNumbers: View {
    @State private var sequence: [String] = []
    @State private var userInput: [String] = []
    @State private var currentStep: Int = 1
    @State private var isShowingSequence: Bool = false
    @State private var currentSequenceIndex: Int = 0
    @State private var showWinModal: Bool = false
    @State private var showLoseModal: Bool = false // Управляем отображением модального окна проигрыша
    @AppStorage("coins") private var coins: Int = 0
    @Environment(\.dismiss) private var dismiss

    // Массив с названиями ваших картинок
    private let imageNames = ["11", "12", "13", "14", "15", "16", "17", "18"]

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
                    Image(.memo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 70)
                        .padding()
                    Spacer()
                }

                VStack {
                    if isShowingSequence {
                        Image(sequence[currentSequenceIndex])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                            ForEach(imageNames, id: \.self) { imageName in
                                Button(action: {
                                    handleUserInput(imageName)
                                }) {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                        .padding()
                    }
                }

                // Lose Modal (кастомное модальное окно)
                if showLoseModal {
                    CustomModalView(
                        title: "You lose!",
                        message: "You made a mistake. Try again!",
                        buttonTitle: "Try Again",
                        buttonColor: .red
                    ) {
                        resetGame() // Начинаем новую игру при нажатии на кнопку
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
                    .scaleEffect(1.1)
            )
        }
        .onAppear {
            startNewRound()
        }
    }

    private func startNewRound() {
        userInput = []
        sequence.append(imageNames.randomElement()!)
        isShowingSequence = true
        currentSequenceIndex = 0
        showSequence()
    }

    private func showSequence() {
        guard currentSequenceIndex < sequence.count else {
            isShowingSequence = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            currentSequenceIndex += 1
            showSequence()
        }
    }

    private func handleUserInput(_ input: String) {
        guard !isShowingSequence else { return }

        userInput.append(input)

        if userInput[userInput.count - 1] != sequence[userInput.count - 1] {
            showLoseModal = true // Показываем модальное окно проигрыша
            return
        }

        if userInput.count == sequence.count {
            if currentStep == 6 {
                showWinModal = true
            } else {
                currentStep += 1
                startNewRound()
            }
        }
    }

    private func resetGame() {
        sequence = []
        userInput = []
        currentStep = 1
        isShowingSequence = false
        showWinModal = false
        showLoseModal = false
        startNewRound()
    }
}

// Кастомное модальное окно
struct CustomModalView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let buttonColor: Color
    let action: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8) // Полупрозрачный фон
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(message)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(buttonColor)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
            }
            .padding()
            .frame(width: 300, height: 250)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    RememberNumbers()
}
