//
//  ToggleButtonView.swift
//  Rosie
//
//  Created by Alex on 29.03.2025.
//

import SwiftUI

struct ToggleButtonView: View {
    let name: String
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            Text(name)
                .myfont2(18)
            
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                
                Button {
                    withAnimation {
                        action()
                    }
                } label: {
                    Capsule()
                        .frame(width: 100, height: 40)
                        .foregroundStyle(Color.gradientBlueWhite)
                        .overlay(alignment: isOn ? .trailing : .leading) {
                            Capsule()
                                .frame(width: 40, height: 30)
                                .foregroundStyle(.white)
                                .padding(.horizontal,4)
                        }
                }
                .buttonStyle(.plain)
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }
        }
    }
}

#Preview {
    ToggleButtonView(name: "SOUND", isOn: false, action: {})
        .padding()
        .background(Color.gray)
}
