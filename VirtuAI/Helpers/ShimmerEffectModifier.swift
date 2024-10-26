//
//  ShimmerEffectModifier.swift
//  ConversAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI

extension View {
    func shimmerEffect(isActive: Bool, speed: Double = 2) -> some View {
        self.modifier(ShimmerEffectModifier(isActive: isActive, speed: speed))
    }
}

struct ShimmerEffectModifier: ViewModifier {
    @State private var isAnimating = false
    let isActive: Bool
    let speed: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isActive {
                Color.white
                    .opacity(0.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2)
                            .scaleEffect(x: 0.5, y: 1, anchor: .leading)
                            .offset(x: -200)
                            .mask(
                                Rectangle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white, Color.clear]), startPoint: .leading, endPoint: .trailing))
                                    .rotationEffect(Angle(degrees: 70))
                                    .offset(x: isAnimating ? 400 : -200)
                            )
                            .animation(Animation.linear(duration: 1 / speed).repeatForever(autoreverses: false))
                    )
                    .onAppear {
                        self.isAnimating = true
                    }
            }
        }
    }
}

struct ShimmerEffectModifier_Previews: PreviewProvider {
    static var previews:
    some View {
        ContentView()
        
    }}
