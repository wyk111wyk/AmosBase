//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/13.
//

import SwiftUI

struct PurchaseCompareTable: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    let allItem: [SimplePurchaseItem]
    
    var body: some View {
        if horizontalSizeClass == .compact {
            compactTable()
        }else {
            regularTable()
        }
    }
    
    private func compactTable() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                titleColumns()
                    .padding(.trailing, 25)
                regularColumns()
                    .padding(.trailing, 12)
                premiumColumns()
            }
            .contentBackground(
                color: colorScheme == .light ? .white : .black,
                withMaterial: false
            )
        }
        .padding(.bottom)
    }
    
    private func regularTable() -> some View {
        HStack(spacing: 8) {
            titleColumns()
            Spacer()
            regularColumns()
            premiumColumns()
        }
        .contentBackground(
            color: colorScheme == .light ? .white : .black,
            withMaterial: false
        )
        .padding(.bottom)
    }
    
    private func titleColumns() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle().foregroundStyle(.clear)
                .frame(height: 20)
            ForEach(allItem) { item in
                VStack(spacing: 4) {
                    item.icon
                        .imageModify(length: 42)
                    Text(item.title)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.8)
                }
                .frame(height: 88)
            }
        }
    }
    
    private func regularColumns() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regular", bundle: .module)
                .font(.callout.weight(.light))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .frame(height: 14)
            Divider()
            ForEach(allItem) { item in
                Text(item.regular)
                    .simpleTag(
                        .bg(
                            verticalPad: 6,
                            horizontalPad: 6,
                            cornerRadius: 6,
                            contentFont: .callout.weight(.regular),
                            contentColor: .secondary,
                            bgColor: .secondary
                        )
                    )
                    .frame(height: 88)
            }
        }
    }
    
    private func premiumColumns() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            premiumImage
                .frame(height: 14)
            Divider()
            ForEach(allItem) { item in
                Text(item.premium)
                    .simpleTag(
                        .full(
                            verticalPad: 6,
                            horizontalPad: 6,
                            cornerRadius: 6,
                            contentFont: .callout.weight(.medium),
                            contentColor: .white,
                            bgColor: .init(white: 0.18)
                        )
                    )
                    .frame(height: 88)
            }
        }
    }
    
    private var premiumImage: some View {
        if colorScheme == .light {
            Image(sfImage: .premium)
                .resizable().scaledToFit()
        }else {
            Image(sfImage: .premium_w)
                .resizable().scaledToFit()
        }
    }
}

#Preview {
    var allItem: [SimplePurchaseItem] {
        [
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "学习计划", regular: "仅限预设", premium: "自由创建和更改"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "作品详情", regular: "解析、佳句", premium: "介绍、译文、评论、百科"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "诵读引擎", regular: "系统合成音效", premium: "专项训练的神经网络引擎"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "作品成图", regular: "无法生成图片", premium: "多维定制生成诗词图片"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "数据同步", regular: "仅限本地使用", premium: "多设备无缝实时同步使用"),
            SimplePurchaseItem(icon: Image(sfImage: .lal_nba), title: "多端使用", regular: "多平台", premium: "单次购买 · 多端同享")
        ]
    }
    
    Form {
        PurchaseCompareTable(allItem: allItem)
    }
    #if os(macOS)
        .frame(height: 800)
    #endif
}
