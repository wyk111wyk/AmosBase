//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/21.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public struct SimpleSelectableText: View {
    
    @State private var textViewHeight: CGFloat = 1200
    
    let text: String
    let markdownText: String?
    let attributedText: AttributedString?
    
    var fontSize: CGFloat
    var lineSpace: CGFloat
    var alignment: NSTextAlignment
    var textColor: SFColor
    
    let selectTextCallback: (String) -> ()
    
    public init(
        text: String = "",
        markdown: String? = nil,
        attributedText: AttributedString? = nil,
        fontSize: CGFloat = 18,
        lineSpace: CGFloat = 8,
        alignment: NSTextAlignment = .left,
        textColor: SFColor? = nil,
        selectTextCallback: @escaping (String) -> () = {_ in}
    ) {
        self.text = text
        self.markdownText = markdown
        self.attributedText = attributedText
        self.selectTextCallback = selectTextCallback
        
        self.fontSize = fontSize
        self.lineSpace = lineSpace
        self.alignment = alignment
        if let textColor {
            self.textColor = textColor
        }else {
            #if os(iOS)
            self.textColor = .label
            #elseif os(macOS)
            self.textColor = .labelColor
            #endif
        }
    }

    var attributedString: AttributedString {
        if let attributedText {
            return attributedText
        }else if let markdownText {
            return markdownText.markdown
        }else {
            var attributedString = AttributedString(text)
            #if os(iOS)
            attributedString.uiKit.foregroundColor = textColor
            #elseif os(macOS)
            attributedString.appKit.foregroundColor = textColor
            #endif
            attributedString.font = .systemFont(ofSize: fontSize)
            // 段落设置
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpace
            paragraphStyle.alignment = alignment
            
            attributedString.paragraphStyle = paragraphStyle
            
            return attributedString
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            #if os(iOS)
            SimpleText_iOS(
                attributedString: attributedString,
                calculatedHeight: $textViewHeight,
                selectTextCallback: selectTextCallback
            )
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
            #elseif os(macOS)
            ScrollView {
                SimpleText_mac(
                    attributedString: attributedString,
                    calculatedHeight: $textViewHeight,
                    selectTextCallback: selectTextCallback
                )
                .frame(width: geometry.size.width,
                       height: textViewHeight)
            }
            #endif
        }
    }
}

#Preview("poem") {
    SimpleSelectableText(
        text: String.testText(.chinesePoem) + String.testText(.chinesePoem) + String.testText(.chinesePoem)
    )
}

#Preview("markdown") {
    DemoSimpleText(
        markdown: String.testText(.markdown02)
    )
    .frame(minWidth: 300, minHeight: 500)
}
