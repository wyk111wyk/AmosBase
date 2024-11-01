//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/4/17.
//

import SwiftUI

#if !os(watchOS)
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
        NavigationStack {
            SimpleWebView(
                url: page.url,
                isPushIn: true,
                webType: .mobile
            )
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar{ toolbarMenu() }
        }
    }
}

extension DemoSimpleWeb {
    @ToolbarContentBuilder
    private func toolbarMenu() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $page) {
                Text("虎扑").tag(PageType.hupu)
                Text("NBA官网").tag(PageType.nba)
            }
            .pickerStyle(.segmented)
            .frame(width: 160)
        }
    }
}

#Preview {
    DemoSimpleWeb()
}
#endif
