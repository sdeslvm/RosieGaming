//
//  RulesView.swift
//  Rosie
//
//  Created by Alex on 30.03.2025.
//

import SwiftUI

struct RulesView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Image(.bgimg)
                .resizable()
                .ignoresSafeArea()
            
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(.back)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
                Spacer()
                
                Text("RULES")
                    .myfont2(48)
                
                Text("The player controls a falling flower ball.  They merge two identical balls to create a larger flower.  The goal is to reach the biggest flower without filling up the field.")
                    .myfont2(22)
                
                Text("The player holds their finger to move the ball left and right.  Releasing it drops the ball into the desired position.")
                    .myfont2(22)
                
                Image(.example)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .overlay(alignment: .center) {
                        HStack(spacing: 100) {
                            Image(systemName: "hand.tap")
                            
                            Image(systemName: "hand.draw")
                        }
                        .foregroundStyle(.black)
                        .font(.system(size: 30))
                    }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    RulesView()
}
