//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/4/17.
//

import SwiftUI

public struct DemoSimpleWeb: View {
    enum PageType {
        case hupu, nba
        var url: URL {
            switch self {
            case .hupu:
                return URL(string: "https://m.hupu.com/nba")!
            case .nba:
                return URL(string: "https://china.nba.cn/index")!
            }
        }
    }
    
    @State private var page: PageType = .hupu
    
    public var body: some View {
        #if !os(watchOS)
        NavigationStack {
            SimpleWebView(
                url: page.url,
                isPushIn: true,
                webType: .mobile
            )
            .inlineTitleForNavigationBar()
            .toolbar{ toolbarMenu() }
        }
        #else
        Text("Only for iOS / macOS")
        #endif
    }
}

#if !os(watchOS)
extension DemoSimpleWeb {
    @ToolbarContentBuilder
    private func toolbarMenu() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $page) {
                Text("虎扑").tag(PageType.hupu)
                Text("NBA官网").tag(PageType.nba)
            }
            .segmentStyle()
            .frame(width: 160)
        }
    }
}
#endif

#Preview {
    DemoSimpleWeb()
}
