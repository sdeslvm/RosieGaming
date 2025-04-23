//
//  LoadingView.swift
//  Rosie
//
//  Created by Alex on 31.03.2025.
//

import SwiftUI

struct LoadingView: View {
    
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack {
            Image(.bgimg)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                Spacer()
                
                Text("LOADING..")
                    .myfont2(22)
                Capsule()
                    .stroke(Color.yellow, lineWidth: 1)
                    .frame(width: 300, height: 20)
                    .background(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(Color.rainbowGradient)
                            .frame(width: progress * 295, height: 20)
                            .padding(.horizontal, 4)
                    }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.linear(duration: 0.8)) {
                progress = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
