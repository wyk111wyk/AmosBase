//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI
import Translation
import UniformTypeIdentifiers

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
    
    static func isOptionalPresented<V>(_ value: Binding<V?>) -> Binding<Bool?> {
        Binding<Bool?>(
            get: { value.wrappedValue != nil },
            set: { if $0 == false || $0 == nil { value.wrappedValue = nil } }
        )
    }
}

extension GeometryProxy: @unchecked @retroactive Sendable {}
        
#if !os(watchOS)
public extension View {
    func simpleSearch(
        text: Binding<String>,
        prompt: String? = nil,
        isAlwaysShow: Bool = true
    ) -> some View {
        let promptText: Text? =
        if let prompt { Text(prompt) } else { nil }
        #if os(iOS)
        return self.searchable(
                text: text,
                placement: .navigationBarDrawer(displayMode: isAlwaysShow ? .always : .automatic),
                prompt: promptText
            )
            .searchDictationBehavior(.inline(activation: .onLook))
        #elseif os(macOS)
        return self.searchable(
                text: text,
                placement: .toolbar,
                prompt: promptText
            )
        #endif
    }
    
    func translation(isPresented: Binding<Bool>, text: String) -> some View {
        #if targetEnvironment(macCatalyst)
        return self
        #else
        if #available(iOS 17.4, macOS 14.4, *) {
            return self.translationPresentation(isPresented: isPresented, text: text)
        } else {
            return self
        }
        #endif
    }
}

// 拖拽内容 Drop
public extension View {
    @ViewBuilder func dragText(content: String?) -> some View {
        if let content {
            self.draggable(content)
        }else {
            self
        }
    }
    
    @ViewBuilder func dragImage(content: SFImage?) -> some View {
        if let content {
            self.draggable(content)
        }else {
            self
        }
    }
    
    /// 拖拽接收 Text 内容
    func onDropText(
        isTargeted: Binding<Bool>? = nil,
        textReceive: @escaping (String) -> Void
    ) -> some View {
        self.onDrop(
            of: [.text, .plainText, .utf8PlainText, .utf16PlainText],
            isTargeted: isTargeted
        ) { providers in
            debugPrint("接收到了文字")
            if let provider = providers.first {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.utf8PlainText.identifier) { (data, error) in
                    if let data,
                       let input = String(data: data, encoding: .utf8) {
                        debugPrint("接收到了文字utf8：\(input)")
                        textReceive(input)
                    }
                }
                provider.loadDataRepresentation(forTypeIdentifier: UTType.utf16PlainText.identifier) { (data, error) in
                    if let data,
                       let input = String(data: data, encoding: .utf16) {
                        debugPrint("接收到了文字utf16：\(input)")
                        textReceive(input)
                    }
                }
            }
            return true
        }
    }
    
    /// 拖拽接收 Image 内容
    func onDropImage(
        isTargeted: Binding<Bool>? = nil,
        imageReceive: @escaping (SFImage) -> Void
    ) -> some View {
        self.onDrop(of: [.image, .png, .jpeg, .heic], isTargeted: isTargeted, perform: { providers in
            if let provider = providers.first {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { (data, error) in
                    if let data, let image = SFImage(data: data) {
                        debugPrint("接收到了图片：\(data.count.toDouble.toStorage())")
                        imageReceive(image)
                    }
                }
            }
            return false
        })
    }
}
#endif
