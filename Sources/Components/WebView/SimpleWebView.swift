//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/11.
//

import Foundation
import SwiftUI
#if !os(watchOS)
import WebKit

/// 简单UI组件 -  应用内的浏览器
///
/// 可传入有效的url进行载入，已适配兔小巢用户留言功能
public struct SimpleWebView: View {
    public enum WebType {
        case mobile, desktop
    }
    
    @Environment(\.dismiss) private var dismissPage
    @StateObject private var model = SimpleWebModel()
    
    // 兔小巢的link是 https://support.qq.com/product/{产品id}
    let url: URL
    let account: SimpleFeedbackModel?
    let isPushIn: Bool
    let showReloadButton: Bool
    let webType: WebType
    
    @State private var isLoading = false
    @State private var showErrorAlert: Bool? = false
    
    public init(
        url: URL,
        isPushIn: Bool = false,
        showReloadButton: Bool = true,
        webType: WebType = .mobile,
        account: SimpleFeedbackModel? = nil
    ) {
        self.url = url
        self.isPushIn = isPushIn
        self.showReloadButton = showReloadButton
        self.webType = webType
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
        #if os(iOS)
        SimpleWeb_iOS(
            url: url,
            isloading: $isLoading,
            showErrorAlert: $showErrorAlert,
            account: account,
            model: model,
            webType: webType
        )
        .ignoresSafeArea(.container, edges: .bottom)
        .onChange(of: url) {
//            debugPrint("URL改变：\(new.absoluteString)")
            model.loadRequest(.init(url: url))
        }
        .simpleErrorToast(
            presentState: $showErrorAlert,
            title: "内容载入失败"
        )
        .buttonCircleNavi(
            imageName: "arrow.triangle.2.circlepath",
            isLoading: isLoading
        ) {
            model.reload()
        }
        #elseif os(macOS)
        SimpleWeb_mac(
            url: url,
            isloading: $isLoading,
            showErrorAlert: $showErrorAlert,
            account: account,
            model: model
        )
        .ignoresSafeArea()
        .onChange(of: url) {
            debugPrint("URL改变：\(url.absoluteString)")
            model.loadRequest(.init(url: url))
        }
        .simpleErrorToast(
            presentState: $showErrorAlert,
            title: "内容载入失败"
        )
        .buttonCircleNavi(
            imageName: "arrow.triangle.2.circlepath",
            isLoading: isLoading
        ) {
            model.reload()
        }
        #endif
    }
}

#Preview {
    SimpleWebView(
        url: URL(string: "https://www.baidu.com")!
    )
}
#endif
