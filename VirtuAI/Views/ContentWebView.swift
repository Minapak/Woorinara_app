//
//  ContentView.swift
//  WebView
//
//  Created by Ben Chatelain on 2/3/22.
//

import WebView
import SwiftUI

struct ContentWebView: View {
    @ObservedObject var webViewStore = WebViewStore()
    // 화면 이동을 위한 상태 변수
    @State private var showTranslationView = false
    @State private var showAutoFillView = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 전체 배경색 지정
                Color.background.ignoresSafeArea(.container, edges: [])

                VStack(alignment: .center, spacing: 0) {
                    AppBar(title: "", isMainPage: true)
                    
                   
                   // Spacer()
                    NavigationView {
                        WebView(webView: webViewStore.webView)
                           

                    }.onAppear {
                        self.webViewStore.webView.load(URLRequest(url: URL(string: "https://m.cafe.naver.com")!))
                    }
                   // Spacer()

                }.padding(.bottom, 5)
                .padding(16)
            }
            // NavigationLink를 사용하여 뷰 전환
            .background(
                NavigationLink(destination: PDFClickViewer(), isActive: $showTranslationView) { EmptyView() }
            )
            .background(
                NavigationLink(destination: PDFViewer(), isActive: $showAutoFillView) { EmptyView() }
            )
        }
    }

    func goBack() {
        webViewStore.webView.goBack()
    }

    func goForward() {
        webViewStore.webView.goForward()
    }
}

struct ContentWebView_Previews: PreviewProvider {
    static var previews: some View {
        ContentWebView()
    }
}
