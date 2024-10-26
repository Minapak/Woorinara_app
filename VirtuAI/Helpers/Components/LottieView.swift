//
//  LottieView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 9.06.2023.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName : String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(animationName)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true


        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

