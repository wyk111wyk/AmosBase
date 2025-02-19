//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/17.
//

#if os(macOS)
import Foundation
import SwiftUI
import AppKit

public struct SimpleMacTextView: NSViewRepresentable {
    @Binding var inputText: String
    @Binding var selectedText: String
    @Binding var calculatedHeight: CGFloat
    
    public init(_ inputText: Binding<String>,
         selectedText: Binding<String> = .constant(""),
         calculatedHeight: Binding<CGFloat>) {
        self._inputText = inputText
        self._selectedText = selectedText
        self._calculatedHeight = calculatedHeight
    }

    public func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = false
        textView.autoresizingMask = [.width, .height]
        textView.textContainer?.lineFragmentPadding = 8
        textView.textContainerInset = NSSize(width: 0, height: 8)
        textView.delegate = context.coordinator // 设置代理
        return textView
    }

    public func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = inputText // 更新视图中的文本
        updateHeight(textView: nsView)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SimpleMacTextView

        public init(_ parent: SimpleMacTextView) {
            self.parent = parent
        }

        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.inputText = textView.string // 更新绑定的文本
        }
        
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if let range = Range(textView.selectedRange, in: textView.string) {
                let text = textView.string[range]
                parent.selectedText = String(text)
            }
        }
    }
    
    func updateHeight(textView: NSTextView) {
        // Force layout update
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        let height = textView.layoutManager?.usedRect(for: textView.textContainer!).height ?? 0
        DispatchQueue.main.async {
            self.calculatedHeight = height + 16
//            debugPrint("更新mac高度：\(self.calculatedHeight)")
        }
    }
}

struct SimpleMacTextField: NSViewRepresentable {
    @Binding var inputText: String
    
    init(_ inputText: Binding<String>) {
        self._inputText = inputText
    }

    func makeNSView(context: Context) -> NSTextField {
        let textView = NSTextField()
        textView.stringValue = inputText
        textView.isEditable = true
        textView.isSelectable = true
        textView.maximumNumberOfLines = 4
        textView.isVerticalContentSizeConstraintActive = true
        textView.delegate = context.coordinator // 设置代理
        return textView
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: SimpleMacTextField

        init(_ parent: SimpleMacTextField) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else { return }
            print(textField)
            parent.inputText = textField.stringValue // 更新绑定的文本
        }
    }
}

#Preview("Form") {
    @Previewable @State var input01: String = "单行或多行，但通常用于单行文本:  NSTextField 主要设计用于显示和编辑单行文本。虽然它可以配置为多行，但它的核心功能和优化是针对单行文本的。\n单行或多行，但通常用于单行文本:  NSTextField 主要设计用于显示和编辑单行文本。虽然它可以配置为多行，但它的核心功能和优化是针对单行文本的。单行或多行，但通常用于单行文本:  NSTextField 主要设计用于显示和编辑单行文本。虽然它可以配置为多行，但它的核心功能和优化是针对单行文本的。"
    @Previewable @State var selectedText: String = ""
    @Previewable @State var calculatedHeight: CGFloat = 20
    
    NavigationStack {
        Form {
            SimpleMacTextField($input01)
            
            SimpleMacTextView(
                $input01,
                selectedText: $selectedText,
                calculatedHeight: $calculatedHeight
            )
                .frame(height: calculatedHeight)
        }
        .formStyle(.grouped)
    }
}
#endif
