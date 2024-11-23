import SwiftUI
import WebKit
import SwiftKeychainWrapper

class WebViewStore: NSObject, ObservableObject, WKHTTPCookieStoreObserver, WKScriptMessageHandler {
    @Published var webView: WKWebView

    override init() {
        let configuration = WKWebViewConfiguration()
        let websiteDataStore = WKWebsiteDataStore.default()
        configuration.websiteDataStore = websiteDataStore
        
        // JavaScript 구성
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        // JavaScript 메시지 핸들러 등록
        let userContentController = WKUserContentController()
        configuration.userContentController = userContentController
        
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        
        // 메시지 핸들러 등록
        configuration.userContentController.add(self, name: "iosApp")
        self.webView.configuration.websiteDataStore.httpCookieStore.add(self)
        
        // 초기 웹페이지 로드 및 헤더 설정
        loadInitialPage()
    }
    
    private func loadInitialPage() {
        guard let url = URL(string: "http://43.201.31.70:8000/auth") else {
            print("⚠️ ERROR: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        // 헤더에 토큰 추가
        if let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
           let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") {
            request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("*/*", forHTTPHeaderField: "Accept")
            print("🔐 Tokens set in headers:")
            print("📝 Refresh Token: \(refreshToken)")
            print("📝 Access Token:  \(accessToken)")
        } else {
            print("⚠️ WARNING: No tokens found in KeychainWrapper")
        }
        
        webView.load(request)
    }

    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { cookies in
            print("🍪 Cookies updated:")
            cookies.forEach { cookie in
                print("   - \(cookie.name): \(cookie.value)")
            }
        }
    }

    
    // JavaScript로부터 메시지 수신
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "iosApp" {
            if let messageBody = message.body as? [String: Any] {
                print("📱 Received from JavaScript:", messageBody)
                
                if let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
                   let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") {
                    let response: [String: Any] = [
                        "status": "success",
                        "message": "Data received",
                        "headers": [
                            "refreshToken": refreshToken,
                            "accessToken": accessToken,
                            "contentType": "application/x-www-form-urlencoded",
                            "accept": "*/*"
                        ]
                    ]
                    print("🔄 Sending response to JavaScript with tokens")
                    sendDataToJavaScript(response)
                }
            }
        }
    }

    
    // JavaScript로 데이터 전송
    private func sendDataToJavaScript(_ data: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: data),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let jsCode = "window.vueApp.receiveDataFromiOS('\(jsonString)')"
            webView.evaluateJavaScript(jsCode) { result, error in
                if let error = error {
                    print("Error sending data to JavaScript:", error)
                } else {
                    print("Successfully sent data to JavaScript with tokens")
                }
            }
        }
    }
}


struct WebViewWrapper: UIViewRepresentable {
    let webView: WKWebView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewWrapper
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                print("🔄 Navigating to: \(url.absoluteString)")
                
                if url.absoluteString.contains("/post/new") {
                    print("🆕 Post/New detected")
                    if let body = navigationAction.request.httpBody {
                        print("📝 Form data: \(String(data: body, encoding: .utf8) ?? "")")
                    }
                    
                    var request = navigationAction.request
                    if let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
                       let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") {
                        request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
                        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        print("🔐 Headers reset for post/new request")
                        print("📝 Refresh Token: \(refreshToken)")
                        print("📝 Access Token: Bearer \(accessToken)")
                    }
                    
                    webView.load(request)
                }
            }
            
            if navigationAction.request.httpMethod == "POST" {
                print("📮 POST request detected")
                if let headers = navigationAction.request.allHTTPHeaderFields {
                    print("📋 Request headers:")
                    headers.forEach { key, value in
                        print("   - \(key): \(value)")
                    }
                }
                if let body = navigationAction.request.httpBody {
                    print("📝 Request body: \(String(data: body, encoding: .utf8) ?? "")")
                }
            }
            
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            print("↪️ Received server redirect")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let url = URL(string: "http://43.201.31.70:8000/") {
                    print("🔄 Redirecting to main page")
                    webView.load(URLRequest(url: url))
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Finished loading: \(webView.url?.absoluteString ?? "")")
            
            // completion 버튼 클릭 처리를 위한 JavaScript 주입
            let script = """
            document.addEventListener('click', function(e) {
                if (e.target && e.target.id === 'completion-button') {
                    console.log('Completion button clicked');
                    let form = document.querySelector('form');
                    if (form) {
                        form.submit();
                    }
                }
            });
            """
            
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("❌ JavaScript error: \(error)")
                } else {
                    print("✅ JavaScript injection successful")
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Navigation error: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("⚠️ Provisional navigation error: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("ℹ️ JavaScript Alert: \(message)")
            completionHandler()
        }
        
    }
    
    

}
struct ContentWebView: View {
    @ObservedObject var webViewStore = WebViewStore()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea(.all)
                VStack(spacing: 0) {
                    WebViewWrapper(webView: webViewStore.webView)
                }
            }
        }
    }
}
