//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/11.
//

import Foundation
import SwiftUI
#if !os(watchOS) && !os(macOS)
import WebKit

/// 简单UI组件 -  应用内的浏览器
///
/// 可传入有效的url进行载入，已适配兔小巢用户留言功能
public struct SimpleWebView: View {
    @Environment(\.dismiss) private var dismissPage
    @StateObject private var model = SimpleWebModel()
    
    // 兔小巢的link是 https://support.qq.com/product/{产品id}
    @Binding var url: URL
    let account: SimpleFBUser?
    let isPushIn: Bool
    let showReloadButton: Bool
    
    @State private var isLoading = false
    @State private var showErrorAlert = false
    
    public init(url: Binding<URL>,
                pushIn: Bool = false,
                showReloadButton: Bool = true,
                account: SimpleFBUser? = nil) {
        self._url = url
        self.isPushIn = pushIn
        self.showReloadButton = showReloadButton
        self.account = account
    }
    
    public var body: some View {
        if isPushIn {
            webView()
        }else {
            naviView()
        }
    }
    
    private func naviView() -> some View {
        NavigationStack {
            webView()
                .buttonCircleNavi(role: .cancel) { dismissPage() }
        }
    }
    
    private func webView() -> some View {
        SimpleWebViewVC(url: url,
                        isloading: $isLoading,
                        showErrorAlert: $showErrorAlert,
                        account: account,
                        model: model)
        .simpleAlert(type: .confirmCancel,
                     title: "内容载入失败",
                     message: "请检查网络状况后稍后重试",
                     isPresented: $showErrorAlert)
        .buttonCircleNavi(imageName: "arrow.triangle.2.circlepath",
                          isLoading: isLoading) {
            model.reload()
        }
                          .onChange(of: url) { _ in
                              model.reload()
                          }
    }
}

public struct SimpleWebViewVC: UIViewRepresentable {
    @Binding var isLoading: Bool
    @Binding var showErrorAlert: Bool
    let urlRequest: URLRequest
    @ObservedObject var model: SimpleWebModel
    
    init(url: URL,
         isloading: Binding<Bool>,
         showErrorAlert: Binding<Bool>,
         account: SimpleFBUser?,
         model: SimpleWebModel) {
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
            let login = "nickname=\(account.nickName)&avatar=\(account.avatar)&openid=\(account.openid)&clientInfo=\(clientInfo)&clientVersion=\(clientVersion)&os=\(osVersion)"
            
            request.httpMethod = "POST"
            request.httpBody = login.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        }
        
        self.urlRequest = request
    }
    
    public func makeCoordinator() -> SimpleWebCoordinator {
        SimpleWebCoordinator(for: self)
    }
    
    public func makeUIView(context: UIViewRepresentableContext<SimpleWebViewVC>) -> WKWebView {
        let webview = model.webView
        webview.allowsBackForwardNavigationGestures = true
        webview.navigationDelegate = context.coordinator
        webview.load(self.urlRequest)
        
        return webview
    }
    
    public func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<SimpleWebViewVC>) {
//        webview.load(self.urlRequest)
        //        printDebug("刷新网页")
    }
}

public class SimpleWebCoordinator: NSObject, WKNavigationDelegate {
    
    var parent: SimpleWebViewVC
    init(for parent: SimpleWebViewVC) {
        self.parent = parent
    }
    
    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //        print("1.开始加载网页")
        parent.isLoading = true
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (response, error) in
            if let title = response as? String {
                debugPrint("2.网页加载完毕: \(title)")
            }
        }
        parent.isLoading = false
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("3.加载网页失败，失败原因:\n\(error)")
        parent.isLoading = false
        parent.showErrorAlert = true
    }
}

#Preview {
    SimpleWebView(url: .constant(URL(string: "https://www.baidu.com")!),
                  pushIn: false)
}
#endif
