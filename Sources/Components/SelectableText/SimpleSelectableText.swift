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

extension NSParagraphStyle: @unchecked @retroactive Sendable {}

public struct SimpleSelectableText: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let text: String
    let attributedText: AttributedString?
    
    @State private var textViewHeight: CGFloat = 600
    
    let selectTextCallback: (String) -> ()
    
    public init(
        text: String = "",
        attributedText: AttributedString? = nil,
        selectTextCallback: @escaping (String) -> () = {_ in}
    ) {
        self.text = text
        self.attributedText = attributedText
        self.selectTextCallback = selectTextCallback
    }

    var attributedString: AttributedString {
        if let attributedText {
            return attributedText
        }else {
            var attributedString = AttributedString(text)
            #if os(iOS)
            attributedString.uiKit.foregroundColor = colorScheme == .dark ? .white : .black
            #endif
            attributedString.font = .systemFont(ofSize: 18)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            attributedString.paragraphStyle = paragraphStyle
            
            return attributedString
        }
    }
    
    public var body: some View {
        #if os(iOS)
        PhoneTextView(
            attributedString: attributedString,
            calculatedHeight: $textViewHeight,
            selectTextCallback: selectTextCallback
        ).frame(height: textViewHeight)
        #elseif os(macOS)
        MacTextView(
            attributedString: attributedString,
            calculatedHeight: $textViewHeight,
            selectTextCallback: selectTextCallback
        )
        .frame(height: textViewHeight)
        #endif
    }
}

#Preview("Text") {
    let text = String.testText(.chineseAndEngish) + String.testText(.chinesePoem) +
        String.testText(.chineseStory)
    NavigationStack {
        ScrollView {
            SimpleSelectableText(text: text)
                .padding(.horizontal)
        }
        .navigationTitle("显示内容")
    }
}
