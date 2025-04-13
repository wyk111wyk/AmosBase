//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/12.
//

import SwiftUI

public struct PopToast: View {
    let mode: SimplePopupMode
    let isTop: Bool
    var bgColor: Color? = nil
    
    var title: String? = nil
    var subTitle: String? = nil
    
    #if os(watchOS)
    let bannerSpace: CGFloat = 12
    let bannerLabelSpace: CGFloat = 2
    let horizontalPadding: CGFloat? = 4
    let contentHorizontalPadding: CGFloat = 12
    #else
    let bannerSpace: CGFloat = 15
    let bannerLabelSpace: CGFloat = 4
    let horizontalPadding: CGFloat? = nil
    let contentHorizontalPadding: CGFloat = 24
    #endif
    
    public init(
        mode: SimplePopupMode,
        isTop: Bool = true,
        title: String? = nil,
        subTitle: String? = nil,
        bgColor: Color? = nil
    ){
        self.mode = mode
        self.isTop = isTop
        self.bgColor = bgColor
        self.title = title
        self.subTitle = subTitle
    }
    
    public var body: some View {
        HStack(spacing: bannerSpace){
            mode.bannerIcon(bgColor)
            
            if title != nil || subTitle != nil {
                VStack(alignment: .leading, spacing: bannerLabelSpace){
                    if let title {
                        Text(LocalizedStringKey(title))
                            .lineLimit(2)
                            .font(Font.body.bold())
                            .foregroundStyle(mode.bannerTitleColor(bgColor))
                    }
                    if let subTitle {
                        Text(LocalizedStringKey(subTitle))
                            .lineLimit(3)
                            .font(.footnote)
                            .foregroundStyle(mode.bannerSubTitleColor(bgColor))
                    }
                }
                .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, contentHorizontalPadding)
        .padding(.top, isTop ? 60 : 15)
        .padding(.bottom, isTop ? 15 : 46)
        .frame(maxWidth: .infinity)
        .modifier(
            BackgroundColorModifier(
                bgColor: mode.bannerBgColor(bgColor),
                cornerRadius: 0
            )
        )
        .modifier(ShadowModifier(isTop: isTop))
        .compositingGroup()
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            PopToast(mode: .error, title: String.randomChinese(short: true), subTitle: String.randomChinese(long: true))
            PopToast(mode: .success, title: String.randomChinese(short: true), subTitle: String.randomChinese(medium: true))
            PopToast(mode: .loading, title: "正在载入...")
            PopToast(mode: .systemImage("trash"), title: String.randomChinese(long: true), subTitle: String.randomChinese(long: true), bgColor: .blue)
            PopToast(mode: .text, title: String.randomChinese(short: true), subTitle: String.randomChinese(medium: true))
            PopToast(mode: .error, isTop: false, title: String.randomChinese(short: true), subTitle: String.randomChinese(long: true))
            PopToast(mode: .success, isTop: false, title: String.randomChinese(short: true), subTitle: String.randomChinese(medium: true))
            PopToast(mode: .loading, isTop: false, title: "正在载入...")
            PopToast(mode: .systemImage("trash"), isTop: false, title: String.randomChinese(long: true), subTitle: String.randomChinese(long: true), bgColor: .blue)
            PopToast(mode: .text, isTop: false, title: String.randomChinese(short: true), subTitle: String.randomChinese(medium: true))
        }
    }
    .ignoresSafeArea()
}
