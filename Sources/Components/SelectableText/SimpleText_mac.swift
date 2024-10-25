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

struct SimpleText_mac: NSViewRepresentable {
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
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        
        // 设置显示的文字
        if let variedString {
            textView.textStorage?.setAttributedString( NSAttributedString(variedString))
        }else {
            textView.textStorage?.setAttributedString( NSAttributedString(attributedString))
        }
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.isVerticallyResizable = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 12, height: 10)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(for: self)
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        if let variedString {
            nsView.textStorage?.setAttributedString( NSAttributedString(variedString))
        }
        updateHeight(textView: nsView)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SimpleText_mac
        init(for parent: SimpleText_mac) {
            self.parent = parent
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView,
                  textView.selectedRange().length > 0 else {
                parent.selectTextCallback("")
                return
            }
            if let range: Range = Range(textView.selectedRange(), in: textView.string) {
                debugPrint(textView.string[range])
                parent.selectTextCallback(String(textView.string[range]))
            }
        }
    }
    
    func updateHeight(textView: NSTextView) {
        // Force layout update
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        let height = textView.layoutManager?.usedRect(for: textView.textContainer!).height ?? 0
        DispatchQueue.main.async {
            self.calculatedHeight = height + 20
//            debugPrint("更新mac高度：\(self.calculatedHeight)")
        }
    }
}
#endif

#Preview("markdown") {
    DemoSimpleText(
        markdown: String.testText(.markdown02)
    )
    .frame(minWidth: 300, minHeight: 500)
}
