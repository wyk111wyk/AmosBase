//
//  Untitled.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/24.
//

import Foundation
import SwiftUI
#if os(macOS)
@preconcurrency import WebKit

struct SimpleWeb_mac: NSViewRepresentable {
    
    @Binding var isLoading: Bool
    @Binding var showErrorAlert: Bool?
    @State private var urlRequest: URLRequest
    @ObservedObject var model: SimpleWebModel
    
    init(
        url: URL,
        isloading: Binding<Bool>,
        showErrorAlert: Binding<Bool?>,
        account: SimpleFeedbackModel?,
        model: SimpleWebModel
    ) {
        self._isLoading = isloading
        self._showErrorAlert = showErrorAlert
        self.model = model
        var request: URLRequest = .init(url: url)
        
        if let account = account {
            let clientInfo = SimpleDevice.getFullModel()
            let clientVersion = SimpleDevice.getAppVersion() ?? ""
            let osVersion = SimpleDevice.getSystemName() + " " + SimpleDevice.getSystemVersion()
            
            // 接入兔小巢需要传入open_id, nickname, avatar, 如果少了其中任何一个，登录态的构建的都会失败，其他都是额外数据
            // 兔小巢只将 openid 作为用户身份的唯一标识，故在构造 openid 时需要考虑其唯一性
            let login: String = "nickname=\(account.nickName)&avatar=\(account.avatar)&openid=\(account.openid)&clientInfo=\(clientInfo)&clientVersion=\(clientVersion)&os=\(osVersion)"
            
            request.httpMethod = "POST"
            request.httpBody = login.data(using: .utf8)
            request.setValue(
                "application/x-www-form-urlencoded",
                forHTTPHeaderField: "content-type"
            )
        }
        
        self.urlRequest = request
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(for: self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webview = model.webView
        webview.allowsBackForwardNavigationGestures = true
        webview.navigationDelegate = context.coordinator
        debugPrint("页面开始刷新")
        webview.load(urlRequest)
        
        return webview
    }
    
    func updateNSView(_ webview: WKWebView, context: Context) {
//        debugPrint("页面进行刷新")
//        webview.load(urlRequest)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        var parent: SimpleWeb_mac
        init(for parent: SimpleWeb_mac) {
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
            debugPrint("1.开始加载网页")
            parent.isLoading = true
        }
        
        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            webView.evaluateJavaScript("document.title") { (response, error) in
                if let title = response as? String {
                    debugPrint("2.网页加载完毕: \(title)")
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
