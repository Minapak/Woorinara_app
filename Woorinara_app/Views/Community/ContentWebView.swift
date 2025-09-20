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
        
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
               
        // 초기 웹페이지 로드 및 쿠키 확인
        loadInitialPage()
    }
    
    private func loadInitialPage() {
        guard let url = URL(string: "http://43.201.31.70:8000/auth") else {
            print("⚠️ ERROR: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)

        // AccessToken 및 RefreshToken을 헤더에 추가
        if let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
           let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken") {
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
            print("🔐 Tokens added to headers:")
            print("📝 Authorization: Bearer \(accessToken)")
            print("📝 Refresh-Token: \(refreshToken)")
        } else {
            print("⚠️ WARNING: No tokens found in KeychainWrapper")
        }

        // 쿠키를 요청에 추가 (선택 사항)
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let cookieHeader = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
            self.webView.load(request)
        }
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
                
                let response: [String: Any] = [
                    "status": "success",
                    "message": "Data received from iOS"
                ]
                sendDataToJavaScript(response)
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
                    print("Successfully sent data to JavaScript")
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
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ Finished loading: \(webView.url?.absoluteString ?? "")")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ Navigation error: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("⚠️ Provisional navigation error: \(error.localizedDescription)")
        }
    }
}

struct ContentWebView: View {
    @StateObject var webViewStore = WebViewStore()
    
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
