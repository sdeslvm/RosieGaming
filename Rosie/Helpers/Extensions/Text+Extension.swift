//
//  Text+Extension.swift
//  Rosie
//
//  Created by Alex on 27.03.2025.
//

import SwiftUI

extension Text {
    func myfont(_ size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .bold, design: .serif))
            .foregroundStyle(Color.gradientBlueWhite)
            .shadow(color: .white, radius: 0.5, x: 1, y: 1)
            .multilineTextAlignment(.center)
    }
    
    func myfont2(_ size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .bold, design: .serif))
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 0.5)
            .multilineTextAlignment(.center)
    }
    
    func myfontNumbers(_ size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .bold, design: .serif))
            .foregroundColor(.white)
            .shadow(color: .black, radius: 2, x: 0, y: 1)
            .multilineTextAlignment(.center)
    }
}

struct Text_Extension: View {
    var body: some View {
        VStack {
            Text("ROSIE")
                .myfont2(66)
            
            Text("SCORE")
                .myfont(66)
            
            Text("1234")
                .myfontNumbers(66)
        }
    }
}

#Preview {
    ZStack {
        Image(.bgimg)
        Text_Extension()
    }
}
