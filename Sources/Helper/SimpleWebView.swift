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

// 针对兔小巢账户的结构体
public struct SimpleFBUser: Identifiable {
    public let id: UUID
    // 用户唯一标识，由接入方生成
    let openid: String
    // 用户昵称,不超过8个字
    let nickName: String
    // 用户头像，一般是图片链接 必须要支持https
    let avatar: String
    
    public init(id: UUID = UUID(),
         openid: String,
         nickName: String,
         avatar: String = "https://txc.qq.com/static/desktop/img/products/def-product-logo.png") {
        self.id = id
        self.openid = openid
        self.nickName = nickName
        self.avatar = avatar
    }
}

/// 简单UI组件 -  应用内的浏览器
///
/// 可传入有效的url进行载入，已适配兔小巢用户留言功能
public struct SimpleWebView: View {
    @Environment(\.dismiss) private var dismissPage
    
    // 兔小巢的link是 https://support.qq.com/product/{产品id}
    let url: URL
    let account: SimpleFBUser?
    @State private var isLoading = false
    let isPushIn: Bool
    @State private var showErrorAlert = false
    
    public init(url: URL,
                pushIn: Bool = false,
                account: SimpleFBUser? = nil) {
        self.url = url
        self.isPushIn = pushIn
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
        SimpleWebViewVC(url: url, isloading: $isLoading,
                  showErrorAlert: $showErrorAlert,
                  account: account)
        .simpleAlert(type: .confirmCancel,
                     title: "内容载入失败",
                     message: "请检查网络状况后稍后重试",
                     isPresented: $showErrorAlert)
    }
}

public struct SimpleWebViewVC: UIViewRepresentable {
    
    @Binding var isLoading: Bool
    @Binding var showErrorAlert: Bool
    let urlRequest: URLRequest
    
    init(url: URL,
         isloading: Binding<Bool>,
         showErrorAlert: Binding<Bool>,
         account: SimpleFBUser?) {
        self._isLoading = isloading
        self._showErrorAlert = showErrorAlert
        
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
        let webview = WKWebView()
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
        //        print("2.网页加载完毕")
        parent.isLoading = false
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("3.加载网页失败，失败原因:\n\(error)")
        parent.isLoading = false
        parent.showErrorAlert = true
    }
}

#Preview {
    SimpleWebView(url: URL(string: "https://www.baidu.com")!, pushIn: false)
}
#endif
