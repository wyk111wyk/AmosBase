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

struct PhoneTextView: UIViewRepresentable {
    var attributedString: AttributedString
    @Binding var calculatedHeight: CGFloat
    let selectTextCallback: (String) -> ()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isSelectable = true
        textView.attributedText = NSAttributedString(attributedString)
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(for: self)
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = NSAttributedString(attributedString)
        PhoneTextView.recalculateHeight(view: uiView, result: $calculatedHeight)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: PhoneTextView
        init(for parent: PhoneTextView) {
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
    
    static func recalculateHeight(view: UITextView, result: Binding<CGFloat>) {
        let size = view.sizeThatFits(
            CGSize(
                width: view.frame.size.width,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
        if result.wrappedValue != size.height {
            DispatchQueue.main.async {
                result.wrappedValue = size.height
            }
        }
    }
}
#endif
