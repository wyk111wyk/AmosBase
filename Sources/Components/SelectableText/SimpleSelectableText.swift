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
    @Binding var variedString: AttributedString?
    
    var fontSize: CGFloat
    var lineSpace: CGFloat
    var alignment: NSTextAlignment
    var textColor: SFColor
    
    let isInScroll: Bool
    
    let selectTextCallback: (String) -> ()
    let contentHeightCallback: (CGFloat) -> ()
    
    public init(
        text: String = "",
        markdown: String? = nil,
        attributedText: AttributedString? = nil,
        variedString: Binding<AttributedString?> = .constant(nil),
        fontSize: CGFloat = 18,
        lineSpace: CGFloat = 8,
        alignment: NSTextAlignment = .left,
        textColor: SFColor? = nil,
        isInScroll: Bool = false,
        selectTextCallback: @escaping (String) -> () = {_ in},
        contentHeightCallback: @escaping (CGFloat) -> () = {_ in}
    ) {
        self.text = text
        self.markdownText = markdown
        self.attributedText = attributedText
        self._variedString = variedString
        self.selectTextCallback = selectTextCallback
        self.contentHeightCallback = contentHeightCallback
        
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
            #else
            self.textColor = .black
            #endif
        }
        
        self.isInScroll = isInScroll
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
        #if os(iOS)
        GeometryReader { reader in
            SimpleText_iOS(
                attributedString: attributedString,
                variedString: $variedString,
                calculatedHeight: $textViewHeight,
                selectTextCallback: selectTextCallback
            )
            .onChange(of: textViewHeight) {
                contentHeightCallback(textViewHeight)
            }
        }
        .frameSet(isInScoll: isInScroll, height: textViewHeight)
        .edgesIgnoringSafeArea(.bottom)
        #elseif os(macOS)
        ScrollView {
            SimpleText_mac(
                attributedString: attributedString,
                variedString: $variedString,
                calculatedHeight: $textViewHeight,
                selectTextCallback: selectTextCallback
            )
            .frame(height: textViewHeight)
        }
        .onChange(of: textViewHeight) {
            contentHeightCallback(textViewHeight)
        }
        #endif
    }
}

// 只要包裹在SwiftUI的ScrollView组件中，尺寸无法正确的读取，必需手动赋值
private extension View {
    @ViewBuilder
    func frameSet(
        isInScoll: Bool,
        height: CGFloat
    ) -> some View {
        if isInScoll {
            self.frame(height: height + 1)
        }else {
            self.frame(maxHeight: height)
        }
    }
}

private enum TestText {
    case md1, md2
    var text: String {
        switch self {
        case .md1: .testText(.markdown01)
        case .md2: .testText(.markdownCode)
        }
    }
    mutating func toggle() {
        switch self {
        case .md1: self = .md2
        case .md2: self = .md1
        }
    }
}
#Preview("Change") {
    @Previewable @State var testText: TestText = .md1
    @Previewable @State var mdText: AttributedString? = String.testText(.markdown01).markdown
    
    Button("更改文字") {
        testText.toggle()
    }.buttonStyle(.borderedProminent)
    SimpleSelectableText(
        variedString: $mdText,
        isInScroll: false
    )
        .onChange(of: testText) {
            mdText = testText.text.markdown
        }
}

#Preview("poem") {
    ScrollView {
        VStack {
            SimpleSelectableText(
                text: String.testText(.chinesePoem),
                isInScroll: true
            )
            Divider()
            SimpleSelectableText(
                text: String.testText(.chineseStory),
                isInScroll: true
            )
        }
    }
}

#Preview("markdown") {
    DemoSimpleText(
        markdown: String.testText(.markdownCode)
    )
}
