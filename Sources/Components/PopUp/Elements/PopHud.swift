//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/12.
//

import SwiftUI

public struct PopHud: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let mode: SimplePopupMode
    var bgColor: Color? = nil
    
    var title: String? = nil
    var subTitle: String? = nil
    var systemImage: String? = nil
    
    #if os(watchOS)
    let centerSpace: CGFloat = 6
    let centerLabelSpace: CGFloat = 4
    #else
    let centerSpace: CGFloat = 12
    let centerLabelSpace: CGFloat = 8
    #endif
    
    var minWidth: CGFloat {
        #if os(watchOS)
        return 80
        #else
        if horizontalSizeClass == .compact {
            return 180
        } else {
            return 200
        }
        #endif
    }
    
    var maxWidth: CGFloat {
        #if os(watchOS)
        return 140
        #else
        if horizontalSizeClass == .compact {
            return 220
        } else {
            return 230
        }
        #endif
    }
    
    var minHeight: CGFloat {
        #if os(watchOS)
        return 70
        #else
        if horizontalSizeClass == .compact {
            return 120
        } else {
            return 140
        }
        #endif
    }
    
    public init(
        mode: SimplePopupMode,
        title: String? = nil,
        subTitle: String? = nil,
        systemImage: String? = nil,
        bgColor: Color? = nil
    ){
        self.mode = mode
        self.bgColor = bgColor
        self.title = title
        self.subTitle = subTitle
        self.systemImage = systemImage
    }
    
    var wrappedTitle: String? {
        if mode == .loading {
            if let title {
                return title
            }else {
                return "Loading..."
            }
        }else {
            return title
        }
    }
    
    public var body: some View {
        VStack(spacing: centerSpace) {
            mode.hudIcon(bgColor, systemImage: systemImage)
                .padding(10)
            if wrappedTitle != nil || subTitle != nil {
                VStack(spacing: centerLabelSpace){
                    if let wrappedTitle {
                        if mode == .loading {
                            Text(wrappedTitle.toLocalizedKey(), bundle: .module)
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.textColor(bgColor: bgColor))
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.center)
                        }else {
                            Text(LocalizedStringKey(wrappedTitle))
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.textColor(bgColor: bgColor))
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.center)
                        }
                    }
                    if let subTitle {
                        Text(LocalizedStringKey(subTitle))
                            .font(.footnote)
                            .lineLimit(nil)
                            .foregroundStyle(Color.textColor(bgColor: bgColor, baseColor: .secondary))
                            .padding(.horizontal, 8)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: minWidth, maxWidth: maxWidth,
               minHeight: minHeight,  alignment: .center)
        .modifier(BackgroundColorModifier(bgColor: bgColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .modifier(ShadowModifier())
        .compositingGroup()
    }
}

#Preview("Loading") {
    PopHud(mode: .loading)
}

#Preview {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 15) {
            PopHud(mode: .loading)
            PopHud(mode: .error, title: String.randomChinese(short: true), subTitle: String.randomChinese(medium: true))
            PopHud(mode: .success, title: String.randomChinese(short: true), subTitle: String.randomChinese(medium: true))
            PopHud(mode: .loading)
            PopHud(mode: .systemImage("trash"), title: String.randomChinese(long: true), subTitle: String.randomChinese(long: true), bgColor: .blue)
            PopHud(mode: .text, title: String.randomChinese(short: true), subTitle: String.randomChinese(medium: true))
        }
        .padding()
    }
    .environment(\.locale, .zhHans)
}
