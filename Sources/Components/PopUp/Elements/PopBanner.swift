//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/12.
//

import SwiftUI

public struct PopBanner: View {
    let mode: SimplePopupMode
    var bgColor: Color? = nil
    
    var title: String? = nil
    var subTitle: String? = nil
    var systemImage: String? = nil
    @Binding var variableTitle: String?
    @Binding var variableSubTitle: String?
    
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
    
    var showSystemSetting: Bool
    
    public init(
        mode: SimplePopupMode,
        title: String? = nil,
        subTitle: String? = nil,
        systemImage: String? = nil,
        variableTitle: Binding<String?> = .constant(nil),
        variableSubTitle: Binding<String?> = .constant(nil),
        bgColor: Color? = nil,
        showSystemSetting: Bool = false
    ){
        self.mode = mode
        self.bgColor = bgColor
        self.title = title
        self.subTitle = subTitle
        self.systemImage = systemImage
        self._variableTitle = variableTitle
        self._variableSubTitle = variableSubTitle
        self.showSystemSetting = showSystemSetting
        
        if mode == .noInternet {
            self.bgColor = .yellow
            self.showSystemSetting = true
        }
    }
    
    var wrappedTitle: String? {
        if mode == .loading {
            if let title { return title
            }else { return "Loading..." }
        }else if mode == .noInternet {
            return "Network temporarily unavailable."
        }else {
            return title
        }
    }
    
    var wrappedSubtitle: String? {
        if mode == .noInternet {
            return "Please check system settings and app permissions."
        }else {
            return subTitle
        }
    }
    
    public var body: some View {
        HStack(spacing: bannerSpace){
            mode.bannerIcon(bgColor, systemImage: systemImage)
            
            if wrappedTitle != nil || subTitle != nil {
                VStack(alignment: .leading, spacing: bannerLabelSpace){
                    if let variableTitle {
                        Text(LocalizedStringKey(variableTitle))
                            .lineLimit(2)
                            .font(Font.body.bold())
                            .foregroundStyle(mode.bannerTitleColor(bgColor))
                    }else if let wrappedTitle {
                        if mode == .loading || mode == .noInternet {
                            Text(wrappedTitle.toLocalizedKey(), bundle: .module)
                                .lineLimit(2)
                                .font(Font.body.bold())
                                .foregroundStyle(mode.bannerTitleColor(bgColor))
                        }else {
                            Text(LocalizedStringKey(wrappedTitle))
                                .lineLimit(2)
                                .font(Font.body.bold())
                                .foregroundStyle(mode.bannerTitleColor(bgColor))
                        }
                    }
                    
                    if let variableSubTitle {
                        Text(LocalizedStringKey(variableSubTitle))
                            .lineLimit(3)
                            .font(.footnote)
                            .foregroundStyle(mode.bannerSubTitleColor(bgColor))
                    }else if let wrappedSubtitle {
                        if mode == .noInternet {
                            Text(wrappedSubtitle.toLocalizedKey(), bundle: .module)
                                .lineLimit(3)
                                .font(.footnote)
                                .foregroundStyle(mode.bannerSubTitleColor(bgColor))
                        }else {
                            Text(LocalizedStringKey(wrappedSubtitle))
                                .lineLimit(3)
                                .font(.footnote)
                                .foregroundStyle(mode.bannerSubTitleColor(bgColor))
                        }
                    }
                }
                .multilineTextAlignment(.leading)
            }
            
            if showSystemSetting {
                PlainButton {
                    SimpleDevice.openSystemSetting()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "gear")
                        Text("Settings", bundle: .module)
                    }
                    .simpleTag(.bg(contentFont: .callout, contentColor: .orange, bgColor: .orange))
                }
            }
        }
        .padding(.horizontal, contentHorizontalPadding)
        .padding(.vertical, 8)
        .frame(minWidth: 200, minHeight: 60)
        .modifier(BackgroundColorModifier(bgColor: mode.bannerBgColor(bgColor)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .modifier(ShadowModifier())
        .compositingGroup()
        .padding(.horizontal, horizontalPadding)
    }
}

#Preview("Banner") {
    ScrollView {
        VStack(spacing: 20) {
            PopBanner(
                mode: .error,
                title: String.randomChinese(short: true),
                subTitle: String.randomChinese(medium: true)
            )
            PopBanner(
                mode: .success,
                title: String.randomChinese(short: true),
                subTitle: String.randomChinese(long: true)
            )
            PopBanner(mode: .loading)
                .environment(\.locale, .zhHans)
            PopBanner(
                mode: .systemImage("trash"),
                title: String.randomChinese(medium: true)
            )
            PopBanner(mode: .noInternet).environment(\.locale, .zhHans)
            PopBanner(mode: .noInternet)
            PopBanner(
                mode: .text,
                title: String.randomChinese(short: true),
                subTitle: String.randomChinese(medium: true),
                systemImage: "person.crop.square"
            )
        }
        .scrollIndicators(.hidden)
    }
}
