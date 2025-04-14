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
            ForEach(0..<8) { index in
                VStack(spacing: 20) {
                    if let title = contentTitle(for: index) {
                        Text(title)
                            .font(.title)
                    }
                    contentView(for: index).tag(index)
                }
                .offset(y: index == 0 ? -50 : 0)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    ForEach(0..<8) { index in
                        Button {
                            withAnimation {
                                pageIndex = index
                            }
                        } label: {
                            Text("\(index + 1). \(contentTitle(for: index) ?? "")")
                        }
                    }
                } label: {
                    Image(systemName: "rectangle.on.rectangle.angled")
                }
            }
        }
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
        case 7: "动态时钟"
        default: nil
        }
    }
    
    @ViewBuilder
    private func contentView(for page: Int) -> some View {
        switch page {
        case 0: FlipCard()
        case 1: MovingDashDemo()
        case 2: ScoreChangeDemo()
        case 3: ShakeViewDemo()
        case 4: ShapeChange()
        case 5: ShimmerDemo()
        case 6: BounceView()
        case 7: ClockDemo()
        default: EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        DemoSimpleAnimation()
    }
}
