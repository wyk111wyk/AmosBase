//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/21.
//

import Foundation
import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSFont: @unchecked @retroactive Sendable {}

struct MacTextView: NSViewRepresentable {
    var attributedString: AttributedString
    @Binding var calculatedHeight: CGFloat
    let selectTextCallback: (String) -> ()

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isEditable = false
        textView.isSelectable = true
        textView.isVerticallyResizable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(for: self)
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.textStorage?.setAttributedString(NSAttributedString(attributedString))
        updateHeight(textView: nsView)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacTextView
        init(for parent: MacTextView) {
            self.parent = parent
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                if textView.selectedRange().length > 0 {
                    debugPrint("Mac - 文字选择改变")
                    if let range: Range = Range(textView.selectedRange(), in: textView.string) {
                        debugPrint(textView.string[range])
                        parent.selectTextCallback(String(textView.string[range]))
                    }
                }
            }
        }
    }
    
    func updateHeight(textView: NSTextView) {
        // Force layout update
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        let height = textView.layoutManager?.usedRect(for: textView.textContainer!).height ?? 0
        DispatchQueue.main.async {
            self.calculatedHeight = height
            debugPrint("更新高度：\(self.calculatedHeight)")
        }
    }
}
#endif