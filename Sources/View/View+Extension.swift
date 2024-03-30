//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI

public enum AmosError: Error, Equatable, LocalizedError {
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg
        }
    }
}

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
}

public extension View {
    @ViewBuilder func simpleTagBackground<S: ShapeStyle>(verticalPad: CGFloat = 5,
                                                         horizontalPad: CGFloat = 10,
                                                         contentFont: Font = .caption,
                                                         themeColor: S? = nil,
                                                         contentColor: S = .white,
                                                         cornerRadius: CGFloat = 6,
                                                         bgStyle: S = .blue) -> some View {
        self.modifier(TagBackground(verticalPad: verticalPad,
                                    horizontalPad: horizontalPad,
                                    contentFont: contentFont,
                                    themeColor: themeColor,
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
    let themeColor: S?
    let contentColor: S
    let cornerRadius: CGFloat
    let bgStyle: S
    
    init(verticalPad: CGFloat, 
         horizontalPad: CGFloat,
         contentFont: Font,
         themeColor: S? = nil,
         contentColor: S,
         cornerRadius: CGFloat,
         bgStyle: S) {
        self.verticalPad = verticalPad
        self.horizontalPad = horizontalPad
        self.contentFont = contentFont
        self.themeColor = themeColor
        self.contentColor = contentColor
        self.cornerRadius = cornerRadius
        self.bgStyle = bgStyle
    }
    
    func body(content: Content) -> some View {
        content
            .font(contentFont)
            .padding(.vertical, verticalPad)
            .padding(.horizontal, horizontalPad)
            .foregroundStyle(themeColor != nil ? themeColor! : contentColor)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(themeColor != nil ? themeColor! : bgStyle)
            }
    }
}

#if !os(watchOS)
@available(iOS 16, macOS 13, watchOS 9, *)
public struct SimpleTextField<Menus: View>: View {
    @State private var isTargeted: Bool = false
    @Binding var inputText: String
    let prompt: String
    let startLine: Int
    let endLine: Int
    let tintColor: Color
    let canClear: Bool
    let moreMenus: () -> Menus
    
    public init(_ inputText: Binding<String>,
         prompt: String = "请输入文本",
         startLine: Int = 5,
         endLine: Int = 12,
         tintColor: Color,
         canClear: Bool = true,
         @ViewBuilder moreMenus: @escaping () -> Menus = { EmptyView() }) {
        self._inputText = inputText
        self.prompt = prompt
        self.startLine = startLine
        self.endLine = endLine
        self.tintColor = tintColor
        self.canClear = canClear
        self.moreMenus = moreMenus
    }
    
    public var body: some View {
        TextField("请输入文本",
                  text: $inputText,
                  prompt: Text(prompt),
                  axis: .vertical)
        .lineLimit(startLine...endLine)
        .lineSpacing(4)
        .font(.body)
        .scrollDismissesKeyboard(.automatic)
        .textFieldStyle(.plain)
        .tint(tintColor)
        .padding(.bottom, 28)
        .onDrop(of: ["public.text"], isTargeted: $isTargeted, perform: { providers in
            return true
        })
        .overlay(alignment: .bottomTrailing) {
            Menu {
                moreMenus()
            } label: {
                HStack(spacing: 4) {
                    Text("\(inputText.count) 字")
                        .font(.footnote)
                    if !inputText.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.small)
                            .opacity(0.9)
                    }
                }
                .foregroundColor(.white)
                .padding(.vertical, 2.6)
                .padding(.horizontal, 6)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.secondary)
                        .opacity(0.5)
                }
            } primaryAction: {
                inputText = ""
            }
            .buttonStyle(.plain)
            .disabled(!canClear)
        }
    }
}
#endif
