//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/22.
//

import Foundation
import SwiftUI

public extension View {
    /// 对 View 的下层添加往外扩张的背景
    func contentBackground(
        verticalPadding: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat? = nil,
        shadowY: CGFloat = 0,
        color: Color? = nil,
        withMaterial: Bool = true,
        isAppear: Bool = true
    ) -> some View {
        modifier(ContentBackgroundView(
            verticalPadding: verticalPadding,
            horizontalPadding: horizontalPadding,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowY: shadowY,
            color: color,
            withMaterial: withMaterial,
            isAppear: isAppear
        ))
    }
    
    /// 对 View 进行背景颜色的直接渲染（或玻璃模糊）
    func standardBackground(
        _ bgColor: Color? = nil,
        cornerRadius: CGFloat = 12
    ) -> some View {
        modifier(BackgroundColorModifier(bgColor: bgColor, cornerRadius: cornerRadius))
    }
    
    /// 对 View 添加阴影 自适应黑白主题
    func standardShadow(
        isTop: Bool = true
    ) -> some View {
        modifier(ShadowModifier(isTop: isTop))
    }
}

struct ContentBackgroundView: ViewModifier {
    let verticalPadding: CGFloat?
    let horizontalPadding: CGFloat?
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat?
    let shadowY: CGFloat
    let color: Color?
    let withMaterial: Bool
    let isAppear: Bool
    
    init(
        verticalPadding: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat? = nil,
        shadowY: CGFloat = 0,
        color: Color? = nil,
        withMaterial: Bool = true,
        isAppear: Bool = true
    ){
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
        self.color = color
        self.withMaterial = withMaterial
        self.isAppear = isAppear
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background {
                if isAppear {
                    if let shadowRadius {
                        if let color {
                            if withMaterial {
                                ZStack {
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .foregroundStyle(color)
                                        .opacity(0.6)
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .foregroundStyle(.ultraThickMaterial)
                                        .shadow(radius: shadowRadius, y: shadowY)
                                }
                                .compositingGroup()
                            }else {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(color)
                                    .shadow(radius: shadowRadius, y: shadowY)
                            }
                        }else {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundStyle(.background.secondary)
                                .shadow(radius: shadowRadius, y: shadowY)
                        }
                    }else if let color {
                        if withMaterial {
                            ZStack {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(color)
                                    .opacity(0.6)
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(.ultraThickMaterial)
                            }
                            .compositingGroup()
                        }else {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundStyle(color)
                        }
                    }else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(.background.secondary)
                            .opacity(0.9)
                    }
                }
            }
    }
}

struct BackgroundColorModifier: ViewModifier {
    var bgColor: Color? = nil
    var cornerRadius: CGFloat = 12
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if let bgColor{
            content
                .background(alignment: .center) {
                    bgColor
                }
        }else{
            content
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .blendMode(.overlay)
                        )
                }
        }
    }
}

struct ShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let isTop: Bool
    init(isTop: Bool = true) {
        self.isTop = isTop
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if colorScheme == .light {
            content
                .shadow(
                    color: Color.primary.opacity(0.1),
                    radius: 5,
                    x: isTop ? 0 : 6,
                    y: isTop ? 6 : 0
                )
        }else{
            content
                .shadow(
                    color: Color.primary.opacity(0.14),
                    radius: 8,
                    x: isTop ? 0 : 6,
                    y: isTop ? 6 : 0
                )
        }
    }
}

#Preview("Background") {
    VStack (spacing: 20) {
        Text("Black")
            .contentBackground()
        Text("Color")
            .contentBackground(color: .blue)
        Text("Shadow")
            .contentBackground(shadowRadius: 20)
        Text("Shadow")
            .contentBackground(shadowRadius: 5, color: .green)
    }
}

#Preview("Banner") {
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
            subTitle: String.randomChinese(medium: true)
        )
    }
}

#Preview("HUD") {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 15) {
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

#Preview("Toast") {
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
