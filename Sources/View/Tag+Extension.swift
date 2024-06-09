//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/5.
//

import SwiftUI

public extension View {
    /// 将视图转换为 Tag 的显示形式
    @ViewBuilder func simpleTag(_ config: SimpleTagConfig = .full()) -> some View {
        self.modifier(TagBorder(config: config))
    }
}

public struct SimpleTagConfig {
    // 边距
    let verticalPad: CGFloat
    let horizontalPad: CGFloat
    // 内容
    let contentFont: Font
    let contentColor: Color
    // 外观
    let cornerRadius: CGFloat
    let borderColor: Color
    let bgColor: Color?
    // Tag
    let lineWidth: CGFloat
    
    public init(
        verticalPad: CGFloat = 4,
        horizontalPad: CGFloat = 8,
        cornerRadius: CGFloat = 5,
        lineWidth: CGFloat = 1,
        contentFont: Font = .caption,
        contentColor: Color = .blue,
        borderColor: Color = .blue,
        bgColor: Color? = nil
    ) {
        self.verticalPad = verticalPad
        self.horizontalPad = horizontalPad
        self.contentFont = contentFont
        self.contentColor = contentColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.lineWidth = lineWidth
        self.bgColor = bgColor
    }
    
    public static func border(
        verticalPad: CGFloat = 2,
        horizontalPad: CGFloat = 6,
        cornerRadius: CGFloat = 4,
        lineWidth: CGFloat = 1,
        contentFont: Font = .caption,
        contentColor: Color = .blue,
        borderColor: Color? = nil,
        bgColor: Color? = nil
    ) -> Self {
        .init(verticalPad: verticalPad,
              horizontalPad: horizontalPad,
              cornerRadius: cornerRadius, 
              lineWidth: lineWidth,
              contentFont: contentFont,
              contentColor: contentColor,
              borderColor: borderColor ?? contentColor,
              bgColor: bgColor)
    }
    
    public static func full(
        verticalPad: CGFloat = 5,
        horizontalPad: CGFloat = 10,
        cornerRadius: CGFloat = 6,
        contentFont: Font = .caption,
        contentColor: Color = .white,
        bgColor: Color = .blue
    ) -> Self {
        .init(verticalPad: verticalPad,
              horizontalPad: horizontalPad,
              cornerRadius: cornerRadius,
              contentFont: contentFont,
              contentColor: contentColor,
              borderColor: bgColor,
              bgColor: bgColor)
    }
}

struct TagBorder: ViewModifier {
    let config: SimpleTagConfig
    
    init(config: SimpleTagConfig) {
        self.config = config
    }
    
    func body(content: Content) -> some View {
        content
            .font(config.contentFont)
            .padding(.vertical, config.verticalPad)
            .padding(.horizontal, config.horizontalPad)
            .foregroundStyle(config.contentColor)
            .background {
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(config.borderColor,
                            lineWidth: config.lineWidth)
            }
            .background {
                if let bgColor = config.bgColor {
                    RoundedRectangle(cornerRadius: config.cornerRadius)
                        .foregroundStyle(bgColor)
                }
            }
    }
}
