//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/5.
//

import SwiftUI

public extension View {
    @ViewBuilder func simpleTagBackground<S: ShapeStyle>(verticalPad: CGFloat = 5,
                                                         horizontalPad: CGFloat = 10,
                                                         contentFont: Font = .caption,
                                                         contentColor: S = .white,
                                                         cornerRadius: CGFloat = 6,
                                                         bgStyle: S = .blue) -> some View {
        self.modifier(TagBackground(verticalPad: verticalPad,
                                    horizontalPad: horizontalPad,
                                    contentFont: contentFont,
                                    contentColor: contentColor,
                                    cornerRadius: cornerRadius,
                                    bgStyle: bgStyle))
    }
    
    @ViewBuilder func simpleTagBorder<S: ShapeStyle>(verticalPad: CGFloat = 2,
                                                     horizontalPad: CGFloat = 6,
                                                     contentFont: Font = .caption,
                                                     themeColor: S? = nil,
                                                     contentColor: S = .blue,
                                                     cornerRadius: CGFloat = 4,
                                                     borderStyle: S = .blue,
                                                     lineWidth: CGFloat = 1,
                                                     bgColor: S? = nil) -> some View {
        self.modifier(TagBorder(verticalPad: verticalPad,
                                horizontalPad: horizontalPad,
                                contentFont: contentFont,
                                themeColor: themeColor,
                                contentColor: contentColor,
                                cornerRadius: cornerRadius,
                                borderStyle: borderStyle,
                                lineWidth: lineWidth,
                                bgColor: bgColor))
    }
}

struct TagBorder<S>: ViewModifier where S: ShapeStyle {
    let verticalPad: CGFloat
    let horizontalPad: CGFloat
    let contentFont: Font
    let themeColor: S?
    let contentColor: S
    let cornerRadius: CGFloat
    let borderStyle: S
    let lineWidth: CGFloat
    let bgColor: S?
    
    init(verticalPad: CGFloat,
         horizontalPad: CGFloat,
         contentFont: Font,
         themeColor: S? = nil,
         contentColor: S,
         cornerRadius: CGFloat,
         borderStyle: S,
         lineWidth: CGFloat,
         bgColor: S? = nil) {
        self.verticalPad = verticalPad
        self.horizontalPad = horizontalPad
        self.contentFont = contentFont
        self.themeColor = themeColor
        self.contentColor = contentColor
        self.cornerRadius = cornerRadius
        self.borderStyle = borderStyle
        self.lineWidth = lineWidth
        self.bgColor = bgColor
    }
    
    func body(content: Content) -> some View {
        content
            .font(contentFont)
            .padding(.vertical, verticalPad)
            .padding(.horizontal, horizontalPad)
            .foregroundStyle(themeColor != nil ? themeColor! : contentColor)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(themeColor != nil ? themeColor! : borderStyle,
                            lineWidth: lineWidth)
            }
            .background {
                if let bgColor {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(bgColor)
                }
            }
    }
}

struct TagBackground<S>: ViewModifier where S: ShapeStyle {
    let verticalPad: CGFloat
    let horizontalPad: CGFloat
    let contentFont: Font
    let contentColor: S
    let cornerRadius: CGFloat
    let bgStyle: S
    
    init(verticalPad: CGFloat,
         horizontalPad: CGFloat,
         contentFont: Font,
         contentColor: S,
         cornerRadius: CGFloat,
         bgStyle: S) {
        self.verticalPad = verticalPad
        self.horizontalPad = horizontalPad
        self.contentFont = contentFont
        self.contentColor = contentColor
        self.cornerRadius = cornerRadius
        self.bgStyle = bgStyle
    }
    
    func body(content: Content) -> some View {
        content
            .font(contentFont)
            .padding(.vertical, verticalPad)
            .padding(.horizontal, horizontalPad)
            .foregroundStyle(contentColor)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(bgStyle)
            }
    }
}
