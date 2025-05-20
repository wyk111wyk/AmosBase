//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/12.
//

import SwiftUI

public struct PopToast: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let mode: SimplePopupMode
    let isTop: Bool
    var bgColor: Color? = nil
    
    var title: String? = nil
    var subTitle: String? = nil
    let bundle: Bundle
    
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    
    #if os(watchOS)
    let bannerSpace: CGFloat = 12
    let bannerLabelSpace: CGFloat = 2
    let horizontalPadding: CGFloat? = 4
    let contentHorizontalPadding: CGFloat = 12
    #elseif os(iOS)
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
        bundle: Bundle = .main,
        bgColor: Color? = nil
    ){
        self.mode = mode
        self.isTop = isTop
        self.bgColor = bgColor
        self.title = title
        self.subTitle = subTitle
        self.bundle = bundle
        #if os(watchOS)
        topPadding = 12
        bottomPadding = 12
        #elseif os(iOS)
        if SimpleDevice.getDevice() == .pad {
            topPadding = 20
            bottomPadding = 20
        }else {
            topPadding = 60
            bottomPadding = 46
        }
        #else
        topPadding = 20
        bottomPadding = 20
        #endif
    }
    
    public var body: some View {
        HStack(spacing: bannerSpace){
            mode.bannerIcon(bgColor)
            
            if title != nil || subTitle != nil {
                VStack(alignment: .leading, spacing: bannerLabelSpace){
                    if let title {
                        Text(LocalizedStringKey(title), bundle: bundle)
                            .lineLimit(2)
                            .font(Font.body.bold())
                            .foregroundStyle(mode.bannerTitleColor(bgColor))
                    }
                    if let subTitle {
                        Text(LocalizedStringKey(subTitle), bundle: bundle)
                            .lineLimit(3)
                            .font(.footnote)
                            .foregroundStyle(mode.bannerSubTitleColor(bgColor))
                    }
                }
                .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, contentHorizontalPadding)
        .padding(.top, isTop ? topPadding : 15)
        .padding(.bottom, isTop ? 15 : bottomPadding)
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
