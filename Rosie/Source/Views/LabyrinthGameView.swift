import SwiftUI
import SpriteKit

// Определяем структуру GridPosition, которая конформит Hashable
struct GridPosition: Hashable {
    var row: Int
    var col: Int
}

class GameSceneNew: SKScene {
    let cellSize: CGFloat = 30 // Размер ячейки
    let mazeRows = 10
    let mazeCols = 10
    var ball: SKSpriteNode!
    var maze: [[Int]] = []
    var ballGridPosition = GridPosition(row: 0, col: 0)
    var coinNode: SKSpriteNode?
    var coinGridPosition: GridPosition?
    var onWin: (() -> Void)? // Closure для SwiftUI

    override func didMove(to view: SKView) {
        backgroundColor = .clear // Прозрачный фон
        size = CGSize(width: 300, height: 300) // Фиксированный размер лабиринта
        maze = generateMaze(rows: mazeRows, cols: mazeCols)
        buildMaze(from: maze)
        addBall()
        addCoin()
        reset()
    }
    
    func reset() {
            removeAllChildren() // Удаляем все узлы
//            mazeWalls.removeAll() // Очищаем стены
            maze = generateMaze(rows: mazeRows, cols: mazeCols)
            buildMaze(from: maze)
            addBall()
            addCoin()
        }

    // Генерация лабиринта с гарантией связности всех проходов
    func generateMaze(rows: Int, cols: Int) -> [[Int]] {
        var maze = Array(repeating: Array(repeating: 1, count: cols), count: rows)
        var stack: [GridPosition] = []
        var visited: Set<GridPosition> = []

        func isValid(_ r: Int, _ c: Int) -> Bool {
            return r >= 0 && r < rows && c >= 0 && c < cols && !visited.contains(GridPosition(row: r, col: c))
        }

        func getNeighbors(_ r: Int, _ c: Int) -> [GridPosition] {
            let directions = [(0, 2), (2, 0), (0, -2), (-2, 0)]
            return directions.compactMap { (dr, dc) in
                let nr = r + dr
                let nc = c + dc
                return isValid(nr, nc) ? GridPosition(row: nr, col: nc) : nil
            }
        }

        var current = GridPosition(row: 0, col: 0)
        visited.insert(current)
        stack.append(current)

        while !stack.isEmpty {
            let pos = current
            maze[pos.row][pos.col] = 0

            let neighbors = getNeighbors(pos.row, pos.col)
            if !neighbors.isEmpty {
                let next = neighbors.randomElement()!
                maze[(pos.row + next.row) / 2][(pos.col + next.col) / 2] = 0
                visited.insert(next)
                stack.append(next)
                current = next
            } else {
                current = stack.removeLast()
            }
        }

        // Добавляем случайные движения шарика для создания дополнительных проходов
        for _ in 0..<5 { // Добавляем 5 случайных движений
            var currentPos = GridPosition(row: 0, col: 0)
            for _ in 0..<10 { // Максимум 10 шагов
                let directions = ["up", "down", "left", "right"]
                let randomDirection = directions.randomElement()!
                switch randomDirection {
                case "up":
                    if currentPos.row > 0 && maze[currentPos.row - 1][currentPos.col] == 1 {
                        maze[currentPos.row - 1][currentPos.col] = 0
                        currentPos.row -= 1
                    }
                case "down":
                    if currentPos.row < mazeRows - 1 && maze[currentPos.row + 1][currentPos.col] == 1 {
                        maze[currentPos.row + 1][currentPos.col] = 0
                        currentPos.row += 1
                    }
                case "left":
                    if currentPos.col > 0 && maze[currentPos.row][currentPos.col - 1] == 1 {
                        maze[currentPos.row][currentPos.col - 1] = 0
                        currentPos.col -= 1
                    }
                case "right":
                    if currentPos.col < mazeCols - 1 && maze[currentPos.row][currentPos.col + 1] == 1 {
                        maze[currentPos.row][currentPos.col + 1] = 0
                        currentPos.col += 1
                    }
                default: break
                }
            }
        }

        return maze
    }

    // Построение лабиринта с непрерывными стенами
    func buildMaze(from maze: [[Int]]) {
        let wallThickness: CGFloat = 6 // Толщина стен
        let halfCellSize = cellSize / 2

        // Создаем внешнюю рамку
        let borderRect = CGRect(x: 0, y: 0, width: cellSize * CGFloat(mazeCols), height: cellSize * CGFloat(mazeRows))
        let border = SKShapeNode(rect: borderRect)
        border.position = CGPoint(x: 0, y: 0)
        border.strokeColor = .white
        border.lineWidth = 12
        border.zPosition = 1000 // поверх всего
        addChild(border)

        // Создаем единый путь для всех внутренних стен
        let path = CGMutablePath()
        for i in 0..<mazeRows {
            for j in 0..<mazeCols {
                if maze[i][j] == 1 {
                    let position = gridToPosition(GridPosition(row: i, col: j))

                    // Верхняя граница
                    if i == 0 || maze[i - 1][j] == 0 {
                        path.move(to: CGPoint(x: position.x - halfCellSize, y: position.y + halfCellSize))
                        path.addLine(to: CGPoint(x: position.x + halfCellSize, y: position.y + halfCellSize))
                    }

                    // Нижняя граница
                    if i == mazeRows - 1 || maze[i + 1][j] == 0 {
                        path.move(to: CGPoint(x: position.x - halfCellSize, y: position.y - halfCellSize))
                        path.addLine(to: CGPoint(x: position.x + halfCellSize, y: position.y - halfCellSize))
                    }

                    // Левая граница
                    if j == 0 || maze[i][j - 1] == 0 {
                        path.move(to: CGPoint(x: position.x - halfCellSize, y: position.y + halfCellSize))
                        path.addLine(to: CGPoint(x: position.x - halfCellSize, y: position.y - halfCellSize))
                    }

                    // Правая граница
                    if j == mazeCols - 1 || maze[i][j + 1] == 0 {
                        path.move(to: CGPoint(x: position.x + halfCellSize, y: position.y + halfCellSize))
                        path.addLine(to: CGPoint(x: position.x + halfCellSize, y: position.y - halfCellSize))
                    }
                }
            }
        }

        // Создаем единый объект SKShapeNode для всех стен
        let walls = SKShapeNode(path: path)
        walls.strokeColor = .white
        walls.lineWidth = wallThickness
        walls.zPosition = 300
        addChild(walls)
    }

    func addBall() {
        ballGridPosition = GridPosition(row: 0, col: 0)
        if let ballTexture = SKTexture(imageNamed: "ball") as SKTexture? {
            ball = SKSpriteNode(texture: ballTexture)
            ball.size = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        } else {
            print("Ошибка: Не удалось загрузить изображение 'ball'")
            return
        }
        ball.position = gridToPosition(ballGridPosition)
        addChild(ball)
    }

    func moveBall(direction: String) {
        var currentPos = ballGridPosition
        switch direction {
        case "up": currentPos.row -= 1
        case "down": currentPos.row += 1
        case "left": currentPos.col -= 1
        case "right": currentPos.col += 1
        default: break
        }
        if currentPos.row >= 0 && currentPos.row < mazeRows &&
           currentPos.col >= 0 && currentPos.col < mazeCols &&
           maze[currentPos.row][currentPos.col] == 0 {
            ballGridPosition = currentPos
            let newPos = gridToPosition(ballGridPosition)
            ball.run(SKAction.move(to: newPos, duration: 0.1))
            if let coinPos = coinGridPosition, coinPos == ballGridPosition {
                coinNode?.removeFromParent()
                coinNode = nil
                onWin?()
            }
        }
    }

    func addCoin() {
        var freeCells: [GridPosition] = []
        for i in 0..<mazeRows {
            for j in 0..<mazeCols {
                if maze[i][j] == 0 && !(i == ballGridPosition.row && j == ballGridPosition.col) {
                    freeCells.append(GridPosition(row: i, col: j))
                }
            }
        }
        guard !freeCells.isEmpty else { return }
        let idx = Int.random(in: 0..<freeCells.count)
        let pos = freeCells[idx]
        coinGridPosition = pos
        let coin = SKSpriteNode(texture: SKTexture(imageNamed: "wincoin"))
        coin.size = CGSize(width: cellSize * 0.9, height: cellSize * 0.9)
        coin.position = gridToPosition(pos)
        coin.zPosition = 500
        addChild(coin)
        coinNode = coin
    }

    func gridToPosition(_ pos: GridPosition) -> CGPoint {
        CGPoint(
            x: CGFloat(pos.col) * cellSize + cellSize / 2,
            y: CGFloat(mazeRows - 1 - pos.row) * cellSize + cellSize / 2
        )
    }
}

struct SpriteKitView: UIViewRepresentable {
    @Binding var scene: GameSceneNew
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.backgroundColor = .clear
        scene.scaleMode = .aspectFit
        scene.size = skView.bounds.size
        skView.presentScene(scene)
        return skView
    }
    func updateUIView(_ uiView: SKView, context: Context) {
        if uiView.scene !== scene {
            uiView.presentScene(scene)
        }
    }
}

struct LabView: View {
    @State private var scene = GameSceneNew()
    @State private var showWinView1 = false
    @State private var showLoseModal = false
    @State private var timeLeft = 60
    @State private var timer: Timer? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                VStack {
                    Image(.maze)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 70)
                        .padding()
                    Spacer()
                }
                
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(.back)
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        .padding()
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
                SpriteKitView(scene: $scene)
                    .frame(width: 300, height: 300)
                    .background(Color.clear)
                VStack {
                    Image(.timerPlate)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 120)
                        .padding(.top, 80)
                        .overlay(
                            Text("\(timeLeft)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                                .padding(.top, 115)
                        , alignment: .top)
                    Spacer()
                }
                VStack {
                    Spacer()
                    Image(.plate)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: { scene.moveBall(direction: "up") }) {
                                        Image(.up)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Button(action: { scene.moveBall(direction: "left") }) {
                                        Image(.left)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    }
                                    Spacer().frame(width: 40)
                                    Button(action: { scene.moveBall(direction: "right") }) {
                                        Image(.right)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    }
                                }
                                HStack {
                                    Spacer()
                                    Button(action: { scene.moveBall(direction: "down") }) {
                                        Image(.down)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)
                                    }
                                    Spacer()
                                }
                                Spacer().frame(height: 20)
                            }
                        )
                }
                if showWinView1 {
                    Color.black.opacity(0.8)
                        .edgesIgnoringSafeArea(.all)
                    WinView1()
                        .frame(width: geo.size.width * 0.9, height: geo.size.height * 0.8)
                        .transition(.opacity)
                        .onTapGesture {
                            dismiss()
                        }
                }
                if showLoseModal {
                    LoseModalView(onTryAgain: {
                        restartGame()
                    })
                    .transition(.opacity)
                    .zIndex(2000)
                }
            }
            .navigationBarHidden(true)
            .frame(width: geo.size.width, height: geo.size.height)
            .background(
                Image("backgroundGame")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )
            .onAppear {
                scene.onWin = {
                    timer?.invalidate()
                    withAnimation {
                        showWinView1 = true
                    }
                }
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timeLeft = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if showWinView1 || showLoseModal {
                t.invalidate()
                return
            }
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                t.invalidate()
                withAnimation {
                    showLoseModal = true
                }
            }
        }
    }

    private func restartGame() {
        showWinView1 = false
        showLoseModal = false
        scene = GameSceneNew()
        startTimer()
    }
}

#Preview {
    LabView()
}
