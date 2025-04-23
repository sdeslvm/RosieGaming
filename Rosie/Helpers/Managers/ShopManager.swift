//
//  ShopManager.swift
//  Rosie
//
//  Created by Alex on 31.03.2025.
//

import SwiftUI

enum ShopItemType: String, Codable {
    case background
    case ball
}

struct ShopItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let price: Int
    let type: ShopItemType
    let ballType: String?
    var isPurchased: Bool
    var isEquipped: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, price, isPurchased, isEquipped, type, ballType
    }
    
    init(name: String, price: Int, type: ShopItemType, ballType: String? = nil, isPurchased: Bool = false, isEquipped: Bool = false) {
        self.name = name
        self.price = price
        self.type = type
        self.ballType = ballType
        self.isPurchased = isPurchased
        self.isEquipped = isEquipped
    }
}

@MainActor
final class ShopManager: ObservableObject {
    static let shared = ShopManager()
    
    @Published var backgroundItems: [ShopItem] = []
    @Published var ballItems: [ShopItem] = []
    @Published var currencyBalance: Int {
        didSet {
            UserDefaults.standard.set(currencyBalance, forKey: "currencyBalance")
        }
    }
    
    private var defaultBallsMap: [String: String] = [
        "smallest": "smallest",
        "small": "small",
        "mediumSmall": "mediumSmall",
        "medium": "medium",
        "mediumLarge": "mediumLarge",
        "large": "large",
        "larger": "larger",
        "evenLarger": "evenLarger",
        "almostLargest": "almostLargest",
        "largest": "largest"
    ]
    
    private let backgroundItemsKey = "backgroundItems"
    private let ballItemsKey = "ballItems"
    private let equippedBallsMapKey = "equippedBallsMap"
    
    private init() {
        self.currencyBalance = UserDefaults.standard.integer(forKey: "currencyBalance")
        loadItems()
        initializeDefaultItems()
    }
    
    // MARK: - Public Methods
    
    func purchaseItem(_ item: ShopItem) -> Bool {
        guard !item.isPurchased && currencyBalance >= item.price else {
            return false
        }
        
        currencyBalance -= item.price
        
        if item.type == .background {
            if let index = backgroundItems.firstIndex(where: { $0.id == item.id }) {
                for i in 0..<backgroundItems.count {
                    backgroundItems[i].isEquipped = false
                }
                
                backgroundItems[index].isPurchased = true
                backgroundItems[index].isEquipped = true
            }
            
            NotificationCenter.default.post(name: Notification.Name("RefreshBackground"), object: nil)
        } else if item.type == .ball {
            if let index = ballItems.firstIndex(where: { $0.id == item.id }) {
                ballItems[index].isPurchased = true
                
                if let ballType = item.ballType,
                   !ballItems.contains(where: { $0.ballType == ballType && $0.isPurchased && $0.isEquipped }) {
                    ballItems[index].isEquipped = true
                    updateEquippedBallsMap(ballType: ballType, itemName: item.name)
                }
            }
        }
        
        saveItems()
        return true
    }
    
    func equipItem(_ item: ShopItem) {
        guard item.isPurchased else { return }
        
        if item.type == .background {
            for i in 0..<backgroundItems.count {
                backgroundItems[i].isEquipped = backgroundItems[i].id == item.id
            }
            
            NotificationCenter.default.post(name: Notification.Name("RefreshBackground"), object: nil)
        } else if item.type == .ball, let ballType = item.ballType {
            for i in 0..<ballItems.count {
                if ballItems[i].ballType == ballType {
                    ballItems[i].isEquipped = ballItems[i].id == item.id
                }
            }
            
            updateEquippedBallsMap(ballType: ballType, itemName: item.name)
            
            NotificationCenter.default.post(name: Notification.Name("RefreshBallTextures"), object: nil)
        }
        
        saveItems()
    }
    
    func toggleDefaultBall(for ballType: String) {
        let isUsingDefault = getEquippedBall(forType: ballType) == ballType
        
        if isUsingDefault {
            if let customItem = ballItems.first(where: { $0.ballType == ballType && $0.isPurchased }) {
                equipItem(customItem)
            }
        } else {
            for i in 0..<ballItems.count {
                if ballItems[i].ballType == ballType {
                    ballItems[i].isEquipped = false
                }
            }
            
            defaultBallsMap[ballType] = ballType
            updateEquippedBallsMap(ballType: ballType, itemName: ballType)
            
            NotificationCenter.default.post(name: Notification.Name("RefreshBallTextures"), object: nil)
            
            saveItems()
        }
    }
    
    func addCurrency(amount: Int) {
        currencyBalance += amount
    }
    
    func getEquippedBackground() -> String {
        let equipped = backgroundItems.first { $0.isEquipped }
        return equipped?.name ?? "bgimg"
    }
    
    func getEquippedBall(for type: BallType) -> String {
        return getEquippedBall(forType: type.imageName)
    }
    
    func getEquippedBall(forType ballType: String) -> String {
        for item in ballItems {
            if item.ballType == ballType && item.isEquipped && item.isPurchased {
                return item.name
            }
        }
        
        return ballType
    }
    
    func hasCustomBalls(for ballType: String) -> Bool {
        return ballItems.contains { $0.ballType == ballType && $0.isPurchased }
    }
    
    // MARK: - Private Methods
    
    private func initializeDefaultItems() {
        for type in BallType.allCases {
            let ballType = type.imageName
            defaultBallsMap[ballType] = ballType
        }
    }
    
    private func updateEquippedBallsMap(ballType: String, itemName: String) {
        defaultBallsMap[ballType] = itemName
    }
    
    private func loadItems() {
        if let savedBackgrounds = loadItemsFromUserDefaults(forKey: backgroundItemsKey) as? [ShopItem] {
            backgroundItems = savedBackgrounds
        } else {
            backgroundItems = [
                ShopItem(name: "bgimg", price: 0, type: .background, isPurchased: true, isEquipped: true),
                ShopItem(name: "bgimg1", price: 300, type: .background),
                ShopItem(name: "bgimg2", price: 500, type: .background)
            ]
        }
        
        if let savedBalls = loadItemsFromUserDefaults(forKey: ballItemsKey) as? [ShopItem] {
            ballItems = savedBalls
        } else {
            ballItems = [
                ShopItem(name: "smallest1", price: 800, type: .ball, ballType: "smallest"),
                ShopItem(name: "small1", price: 800, type: .ball, ballType: "small"),
                ShopItem(name: "mediumSmall1", price: 800, type: .ball, ballType: "mediumSmall"),
                ShopItem(name: "medium1", price: 800, type: .ball, ballType: "medium"),
                ShopItem(name: "mediumLarge1", price: 800, type: .ball, ballType: "mediumLarge"),
                ShopItem(name: "large1", price: 800, type: .ball, ballType: "large"),
                ShopItem(name: "larger1", price: 800, type: .ball, ballType: "larger"),
                ShopItem(name: "evenLarger1", price: 800, type: .ball, ballType: "evenLarger"),
                ShopItem(name: "almostLargest1", price: 800, type: .ball, ballType: "almostLargest"),
                ShopItem(name: "largest1", price: 800, type: .ball, ballType: "largest")
            ]
        }
    }
    
    private func saveItems() {
        saveItemsToUserDefaults(items: backgroundItems, forKey: backgroundItemsKey)
        saveItemsToUserDefaults(items: ballItems, forKey: ballItemsKey)
    }
    
    private func loadItemsFromUserDefaults(forKey key: String) -> Any? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        
        do {
            let items = try JSONDecoder().decode([ShopItem].self, from: data)
            return items
        } catch {
            print("Error loading shop items: \(error)")
            return nil
        }
    }
    
    private func saveItemsToUserDefaults(items: [ShopItem], forKey key: String) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error saving shop items: \(error)")
        }
    }
}
