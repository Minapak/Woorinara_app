//
//  LazyView.swift
//  VirtuAI
//
//  Created by Murat ÖZTÜRK on 7.06.2023.
//

import SwiftUI

// If you have many NavigationLink in ForEach its laggy if you want to make faster load, use LazyView warp your destination
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
