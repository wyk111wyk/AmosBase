//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/21.
//

import Foundation
import SwiftUI
#if canImport(UIKit) && !os(watchOS)
import UIKit

struct SimpleText_iOS: UIViewRepresentable {
    var attributedString: AttributedString
    @Binding var variedString: AttributedString?
    
    @Binding var calculatedHeight: CGFloat
    let selectTextCallback: (String) -> ()
    
    init(
        attributedString: AttributedString,
        variedString: Binding<AttributedString?> = .constant(nil),
        calculatedHeight: Binding<CGFloat>,
        selectTextCallback: @escaping (String) -> () = {_ in}
    ) {
        self.attributedString = attributedString
        self._variedString = variedString
        self._calculatedHeight = calculatedHeight
        self.selectTextCallback = selectTextCallback
    }
    
    func makeUIView(context: Context) -> UITextView {
//        debugPrint("makeUIView")
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        // 设置显示的文字
        if let variedString {
            textView.attributedText = NSAttributedString(variedString)
        }else {
            textView.attributedText = NSAttributedString(attributedString)
        }
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.widthTracksTextView = true
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
        textView.backgroundColor = .clear
        
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(for: self)
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
//        debugPrint("updateUIView")
//        debugPrint(uiView)
        if let variedString {
            uiView.attributedText = NSAttributedString(variedString)
        }
        Self.recalculateHeight(
            view: uiView,
            result: $calculatedHeight
        )
//        debugPrint("View width: \(uiView.frame.size.width)")
//        debugPrint("New text height: \(calculatedHeight)")
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SimpleText_iOS
        init(for parent: SimpleText_iOS) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
//            debugPrint("iOS - textViewDidChange")
//            debugPrint(textView.text.wrapped)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
//            debugPrint("iOS - 文字选择改变")
//            debugPrint(textView.selectedRange)
            guard textView.selectedRange.length > 0 else {
                parent.selectTextCallback("")
                return
            }
            if let range: Range = Range(textView.selectedRange, in: textView.text) {
//                debugPrint(textView.text[range])
                parent.selectTextCallback(String(textView.text[range]))
            }
        }
    }
    
    static func recalculateHeight(
        view: UITextView,
        result: Binding<CGFloat>
    ) {
        let size = view.sizeThatFits(
            CGSize(
                width: view.frame.size.width,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        if result.wrappedValue != size.height {
            DispatchQueue.main.async {
                result.wrappedValue = size.height
//                debugPrint("更新iOS高度：\(size.height)")
            }
        }
    }
}
#endif

#Preview("poem") {
    ScrollView {
        VStack {
            DemoSimpleText(
                text: String.testText(.chineseStory)
            )
            Text("Hello World")
        }
    }
}

#Preview("code") {
    DemoSimpleText(
        markdown: String.testText(.markdownCode)
    )
}
