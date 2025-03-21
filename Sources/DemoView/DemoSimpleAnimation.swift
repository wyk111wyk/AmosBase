//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/21.
//

import SwiftUI

struct DemoSimpleAnimation: View {
    @State private var pageIndex: Int = 0
    var body: some View {
        TabView(selection: $pageIndex) {
            ForEach(0..<7) { index in
                contentView(for: index).tag(index)
                    .overlay(alignment: .top) {
                        if let title = contentTitle(for: index) {
                            Text(title)
                                .font(.title)
                                .offset(y: -80)
                        }
                    }
            }
        }
        #if os(iOS)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        #endif
    }
    
    private func contentTitle(for page: Int) -> String? {
        switch page {
        case 0: "翻转卡片"
        case 1: "移动虚线"
        case 2: "数字变化"
        case 3: "抖动视图"
        case 4: "形状转换"
        case 5: "文字闪烁"
        case 6: "弹性跳跃"
        default: nil
        }
    }
    
    private func contentView(for page: Int) -> some View {
        switch page {
        case 0: return FlipCard()
        case 1: return MovingDashDemo()
        case 2: return ScoreChangeDemo()
        case 3: return ShakeViewDemo()
        case 4: return ShapeChange()
        case 5: return AnimaTextShimmer()
                .padding()
                .background(.gray.tertiary, in: Capsule())
        case 6: return BounceView()
        default: return EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        DemoSimpleAnimation()
    }
}
