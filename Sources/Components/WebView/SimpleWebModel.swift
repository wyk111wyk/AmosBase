//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/17.
//

import Foundation
#if !os(watchOS)
import WebKit

public class SimpleWebModel: ObservableObject {
    var webView: WKWebView = WKWebView()
    
    init() {
        self.webView = WKWebView()
    }
    
    // 刷新页面的方法
    func reload() {
        debugPrint("刷新网页")
        webView.reload()
    }
    
    // 加载新请求的方法
    func loadRequest(_ request: URLRequest) {
        debugPrint("加载网页")
        webView.load(request)
    }
}
#endif
