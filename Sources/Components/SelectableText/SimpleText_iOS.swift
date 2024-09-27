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
    @Binding var calculatedHeight: CGFloat
    let selectTextCallback: (String) -> ()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isSelectable = true
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        textView.attributedText = NSAttributedString(attributedString)
        textView.backgroundColor = .clear
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(for: self)
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = NSAttributedString(attributedString)
        SimpleText_iOS.recalculateHeight(
            view: uiView,
            result: $calculatedHeight
        )
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
            guard textView.selectedRange.length > 0 else { return }
//            debugPrint("iOS - 文字选择改变")
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
    DemoSimpleText(
        text: String.testText(.markdown01)
    )
}
