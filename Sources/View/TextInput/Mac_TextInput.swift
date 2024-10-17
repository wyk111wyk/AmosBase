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

struct SimpleMacTextView: NSViewRepresentable {
    @Binding var inputText: String
    
    init(_ inputText: Binding<String>) {
        self._inputText = inputText
    }

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isHorizontallyResizable = true
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width, .height]
        textView.delegate = context.coordinator // 设置代理
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = inputText // 更新视图中的文本
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SimpleMacTextView

        init(_ parent: SimpleMacTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.inputText = textView.string // 更新绑定的文本
        }
    }
}

#Preview("Form") {
    @Previewable @State var input01: String = "123"
    
    NavigationStack {
        Form {
            SimpleMacTextView($input01)
                .frame(width: 300, height: 200)
        }
        .formStyle(.grouped)
    }
}
#endif
