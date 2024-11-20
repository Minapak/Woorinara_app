
import SwiftUI
import WebKit
import SwiftKeychainWrapper

class WebViewStore: NSObject, ObservableObject, WKHTTPCookieStoreObserver {
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
        
        self.webView.configuration.websiteDataStore.httpCookieStore.add(self)
    }
    
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        cookieStore.getAllCookies { cookies in
            print("Cookies updated: \(cookies)")
        }
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let webView: WKWebView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: "http://43.201.31.70:8000/") else {
            fatalError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        
        if let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
           let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") {
            request.addValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("*/*", forHTTPHeaderField: "Accept")
        }
        
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(request)
        
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
                print("Navigating to: \(url.absoluteString)")
                
                // completion 버튼 클릭 감지
                if url.absoluteString.contains("/post/new") {
                    if let body = navigationAction.request.httpBody {
                        print("Form data: \(String(data: body, encoding: .utf8) ?? "")")
                    }
                    
                    // 폼 제출 시 헤더 재설정
                    var request = navigationAction.request
                    if let refreshToken = KeychainWrapper.standard.string(forKey: "refreshToken"),
                       let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") {
                        request.setValue(refreshToken, forHTTPHeaderField: "Refresh-Token")
                        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    }
                    
                    // 수정된 요청으로 로드
                    webView.load(request)
                }
            }
            
            // POST 요청 로그
            if navigationAction.request.httpMethod == "POST" {
                print("POST request detected")
                if let headers = navigationAction.request.allHTTPHeaderFields {
                    print("Request headers: \(headers)")
                }
                if let body = navigationAction.request.httpBody {
                    print("Request body: \(String(data: body, encoding: .utf8) ?? "")")
                }
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            print("Received server redirect")
            // 리다이렉트 발생 시 메인 페이지로 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let url = URL(string: "http://43.201.31.70:8000/") {
                    webView.load(URLRequest(url: url))
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Finished loading: \(webView.url?.absoluteString ?? "")")
            
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
                    print("JavaScript error: \(error)")
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Navigation error: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Provisional navigation error: \(error.localizedDescription)")
        }
        
        // JavaScript alert 처리
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("JavaScript Alert: \(message)")
            completionHandler()
        }
        
        // JavaScript confirm 처리
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
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

