//
//  ShimmerEffect.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 4.06.2023.
//

import SwiftUI

extension View {
    @ViewBuilder
    func shimmer( config: ShimmerConfig) -> some View {
        self
            .modifier(ShimmerEffectHelper(config: config))
    }
}


//fileprivate struct ShimmerEffectHelper: ViewModifier{
//    var config: ShimmerConfig
//    @State private var moveTo : CGFloat = -0.7
//
//    func body (content: Content) -> some View {
//        content
//            .hidden()
//            .overlay {
//                Rectangle()
//                    .fill(config.tint)
//                    .mask {
//                        content
//                    }
//                    .overlay{
//
//                        GeometryReader {
//                            let size = $0.size
//
//                            Rectangle()
//                                .fill (config.highlight)
//                                .mask{
//                                    Rectangle()
//                                        .fill(
//                                            .linearGradient(colors:[
//                                                .white.opacity(0),
//                                                config.highlight.opacity(config.highlightOpacity),
//                                                .white.opacity(0)
//                                            ], startPoint: .top, endPoint: .bottom)
//                                        )
//
//                                        .blur (radius: config.blur)
//                                        .rotationEffect(.init(degrees: -70) )
//                                        .offset(x: size.width * moveTo)
//
//                                }
//
//                        }.onAppear{
//                            DispatchQueue.main.async {
//                                withAnimation(Animation.linear(duration: config.speed).repeatForever(autoreverses: false)) {
//                                    moveTo = 1
//                                }
//                            }
//                        }
//
//
//
//                    }
//            }
//    }
//
//}


fileprivate struct ShimmerEffectHelper: ViewModifier {
    var config: ShimmerConfig
    @State private var moveOffset: CGFloat = -1
    @State private var moveTo : CGFloat = -0.7
    func body(content: Content) -> some View {
        ZStack {
            content
            
            GeometryReader {
                let size = $0.size
                
                Rectangle()
                    .fill (config.highlight)
                    .mask{
                        Rectangle()
                            .fill(
                                .linearGradient(colors:[
                                    .white.opacity(0),
                                    config.highlight.opacity(config.highlightOpacity),
                                    .white.opacity(0)
                                ], startPoint: .top, endPoint: .bottom)
                            )
                        
                            .blur (radius: config.blur)
                            .rotationEffect(.init(degrees: -70) )
                            .offset(x: size.width * moveTo)
                        
                    }
                
            }.onAppear{
                DispatchQueue.main.async {
                    withAnimation(Animation.linear(duration: config.speed).repeatForever(autoreverses: false)) {
                        moveTo = 1
                    }
                }
            }
            
        }
    }
}
struct ShimmerConfig{
    var tint: Color
    var highlight: Color
    var blur: CGFloat = 0
    var highlightOpacity: CGFloat = 1
    var speed: CGFloat = 2
}

struct ShimmerEffect_Previews: PreviewProvider {
    static var previews:
    some View {
        LanguagesView()

        
    }}
