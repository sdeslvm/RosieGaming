//
//  ShopView.swift
//  Rosie
//
//  Created by Alex on 30.03.2025.
//

import SwiftUI

struct ShopView: View {
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var shopManager = ShopManager.shared
    
    // Animation properties
    @State private var showBalanceAnimation = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Image(.bgimg)
                .resizable()
                .ignoresSafeArea()
            
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header with Back button and Balance
                HStack(alignment: .top) {
                    // Back button
                    Button {
                        dismiss()
                    } label: {
                        Image(.back)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                    // Currency balance
                    HStack(spacing: 4) {
                        Text("\(shopManager.currencyBalance)")
                            .myfont2(20)
                            .colorMultiply(.yellow)
                            .scaleEffect(showBalanceAnimation ? 1.1 : 1.0)
                        
                        Image(.coin)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                    }
                }
                .padding([.horizontal, .top])
                
                // Main content in ScrollView
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Backgrounds section
                        VStack(spacing: 10) {
                            Text("BACKGROUNDS")
                                .myfont2(20)
                            
                            HStack(spacing: 20) {
                                ForEach(shopManager.backgroundItems) { item in
                                    BackgroundItemView(item: item)
                                }
                            }
                        }
                        
                        // Balls section with improved grouping
                        BallsGridView()
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true)) {
                showBalanceAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showBalanceAnimation = false
            }
        }
    }
}

// MARK: - PriceView
struct PriceView: View {
    let price: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(price)")
                .myfont2(14)
                .colorMultiply(.yellow)
            
            Image(.coin)
                .resizable()
                .scaledToFit()
                .frame(width: 35)
        }
    }
}

// MARK: - ActionButtonView
struct ActionButtonView: View {
    let isPurchased: Bool
    let isEquipped: Bool
    let onAction: () -> Void
    
    var body: some View {
        Button(action: onAction) {
            Text(buttonText)
                .myfont2(16)
                .colorMultiply(buttonColor)
                .shadow(color: buttonColor, radius: 5, x: 1, y: 1)
        }
        .disabled(isEquipped)
        .opacity(isEquipped ? 0.7 : 1.0)
    }
    
    private var buttonText: String {
        if isPurchased {
            return isEquipped ? "EQUIPPED" : "EQUIP"
        } else {
            return "BUY"
        }
    }
    
    private var buttonColor: Color {
        if isEquipped {
            return .green
        } else {
            return .yellow
        }
    }
}

// MARK: - BackgroundItemView
struct BackgroundItemView: View {
    @ObservedObject var shopManager = ShopManager.shared
    let item: ShopItem
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Image(item.name)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 180)
                .clipShape(.rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(item.isEquipped ? Color.yellow : Color.clear, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.5), radius: 3)
                .overlay(
                    Group {
                        if !item.isPurchased {
                            PriceView(price: item.price)
                                .transition(.scale)
                        }
                    },
                    alignment: .topTrailing
                )
            
            ActionButtonView(
                isPurchased: item.isPurchased,
                isEquipped: item.isEquipped
            ) {
                handleAction()
            }
        }
        .padding(.top, 8)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("SHOP"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleAction() {
        if item.isPurchased {
            if !item.isEquipped {
                shopManager.equipItem(item)
            }
        } else {
            if shopManager.currencyBalance >= item.price {
                let success = shopManager.purchaseItem(item)
                if success {
                    alertMessage = "Done!"
                } else {
                    alertMessage = "Error"
                }
            } else {
                alertMessage = "Not enough coins: \(item.price)."
            }
            showingAlert = true
        }
    }
}

// MARK: - BallItemView
struct BallItemView: View {
    @ObservedObject var shopManager = ShopManager.shared
    let item: ShopItem
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var isDefault: Bool {
        guard let ballType = item.ballType else { return false }
        return shopManager.getEquippedBall(forType: ballType) == ballType
    }
    
    private var showDefaultButton: Bool {
        guard let ballType = item.ballType else { return false }
        return item.isPurchased && shopManager.hasCustomBalls(for: ballType)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)
                
                Image(item.name)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
            .frame(width: 80, height: 80)
            .overlay(
                Circle()
                    .stroke(item.isEquipped ? Color.yellow : Color.clear, lineWidth: 2)
            )
            .overlay(
                Group {
                    if !item.isPurchased {
                        PriceView(price: item.price)
                            .transition(.scale)
                    }
                },
                alignment: .topTrailing
            )
            
            VStack(spacing: 4) {
                ActionButtonView(
                    isPurchased: item.isPurchased,
                    isEquipped: item.isEquipped
                ) {
                    handleAction()
                }
                
                
                if showDefaultButton {
                    Button(action: {
                        toggleDefaultBall()
                    }) {
                        Text(isDefault ? "CUSTOM" : "DEFAULT")
                            .myfont2(12)
                            .colorMultiply(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(8)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("SHOP"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleAction() {
        if item.isPurchased {
            if !item.isEquipped {
                shopManager.equipItem(item)
                
                NotificationCenter.default.post(name: Notification.Name("RefreshBallTextures"), object: nil)
            }
        } else {
            if shopManager.currencyBalance >= item.price {
                let success = shopManager.purchaseItem(item)
                if success {
                    alertMessage = "Done!"
                    
                    NotificationCenter.default.post(name: Notification.Name("RefreshBallTextures"), object: nil)
                } else {
                    alertMessage = "Error."
                }
            } else {
                alertMessage = "Not enough coins: \(item.price)."
            }
            showingAlert = true
        }
    }
    
    private func toggleDefaultBall() {
        guard let ballType = item.ballType else { return }
        
        shopManager.toggleDefaultBall(for: ballType)
    }
}

// MARK: - BallsGridView
struct BallsGridView: View {
    @ObservedObject var shopManager = ShopManager.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            Text("FLOWERS")
                .myfont2(20)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(shopManager.ballItems) { item in
                    BallItemView(item: item)
                        .frame(height: 130)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    ShopView()
}
