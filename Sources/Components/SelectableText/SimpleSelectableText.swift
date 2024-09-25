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
    
    let selectTextCallback: (String) -> ()
    
    public init(
        text: String = "",
        markdown: String? = nil,
        attributedText: AttributedString? = nil,
        selectTextCallback: @escaping (String) -> () = {_ in}
    ) {
        self.text = text
        self.markdownText = markdown
        self.attributedText = attributedText
        self.selectTextCallback = selectTextCallback
    }

    var attributedString: AttributedString {
        if let attributedText {
            return attributedText
        }else if let markdownText {
            return markdownText.markdown
        }else {
            var attributedString = (try? AttributedString(markdown: text)) ?? AttributedString(text)
            #if os(iOS)
            attributedString.uiKit.foregroundColor = .label
            #elseif os(macOS)
            attributedString.appKit.foregroundColor = .labelColor
            #endif
            attributedString.font = .systemFont(ofSize: 18)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            attributedString.paragraphStyle = paragraphStyle
            
            return attributedString
        }
    }
    
    public var body: some View {
        Group {
            #if os(iOS)
            SimpleText_iOS(
                attributedString: attributedString,
                calculatedHeight: $textViewHeight,
                selectTextCallback: selectTextCallback
            )
            #elseif os(macOS)
            SimpleText_mac(
                attributedString: attributedString,
                calculatedHeight: $textViewHeight,
                selectTextCallback: selectTextCallback
            )
            #endif
        }
        .frame(height: textViewHeight)
    }
}

#Preview("Text") {
    DemoSimpleText(
        markdown: String.testText(.markdown02)
    )
    .frame(minWidth: 300, minHeight: 500)
}
