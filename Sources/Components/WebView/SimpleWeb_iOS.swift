//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/22.
//

import Foundation
import SwiftUI
#if os(iOS)
@preconcurrency import WebKit

struct SimpleWeb_iOS: UIViewRepresentable {
    @Binding var isLoading: Bool
    @Binding var showErrorAlert: Bool?
    @State private var urlRequest: URLRequest
    @ObservedObject var model: SimpleWebModel
    let webType: SimpleWebView.WebType
    
    init(
        url: URL,
        isloading: Binding<Bool>,
        showErrorAlert: Binding<Bool?>,
        account: SimpleFeedbackModel?,
        model: SimpleWebModel,
        webType: SimpleWebView.WebType = .mobile
    ) {
        self._isLoading = isloading
        self._showErrorAlert = showErrorAlert
        self.model = model
        self.webType = webType
        var request: URLRequest = .init(url: url)
        
        if let account = account {
            // 客户端信息
            let clientInfo = SimpleDevice.getFullModel()
            // 客户端版本号
            let clientVersion = SimpleDevice.getAppVersion().wrapped
            // 操作系统
            let os = SimpleDevice.getSystemName() + " " + SimpleDevice.getSystemVersion()
            let customInfo = "weixin:\(account.weixin) email:\(account.email)"
            
            let login: String = "nickname=\(account.nickName)&avatar=\(account.avatar)&openid=\(account.openid)&clientInfo=\(clientInfo)&clientVersion=\(clientVersion)&os=\(os)&customInfo=\(customInfo)"
            
            request.httpMethod = "POST"
            request.httpBody = login.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        }
        
        self.urlRequest = request
    }
    
    func makeCoordinator() -> SimpleWebCoordinator {
        SimpleWebCoordinator(for: self)
    }
    
    func makeUIView(
        context: Context
    ) -> WKWebView {
        let webView = model.webView
        webView.allowsBackForwardNavigationGestures = true
        switch webType {
        case .mobile:
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        case .desktop:
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"
        }
        webView.navigationDelegate = context.coordinator
        webView.load(self.urlRequest)
        
        return webView
    }
    
    func updateUIView(
        _ webview: WKWebView,
        context: Context
    ) {
//        debugPrint("页面进行刷新")
//        webview.load(.init(url: url))
    }
    
    class SimpleWebCoordinator: NSObject, WKNavigationDelegate {
        
        var parent: SimpleWeb_iOS
        init(for parent: SimpleWeb_iOS) {
            self.parent = parent
        }
        
        func webView(
            _ webView: WKWebView,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (
                URLSession.AuthChallengeDisposition,
                URLCredential?
            ) -> Void
        ) {
            completionHandler(.performDefaultHandling, nil)
        }
        
        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            //        print("1.开始加载网页")
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//            debugPrint("收到了 Redirect 信息：\(navigation.debugDescription)")
        }
        
        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            webView.evaluateJavaScript("document.title") { (response, error) in
                if let _ = response as? String {
    //                debugPrint("2.网页加载完毕: \(title)")
                }
            }
            parent.isLoading = false
        }
        
        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            print("3.加载网页失败，失败原因:\n\(error)")
            if (error as NSError).code != NSURLErrorCancelled {
                parent.showErrorAlert = true
            }
            parent.isLoading = false
        }
    }
}

#Preview {
    SimpleWebView(
        url: URL(string: "https://www.baidu.com")!
    )
}
#endif
