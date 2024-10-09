//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI
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
// 拖拽内容 Drop
public extension View {
    @ViewBuilder func dragText(content: String?) -> some View {
        if let content {
            self.draggable(content)
        }else {
            self
        }
    }
    
    @available(macOS 14.0, *)
    @ViewBuilder func dragImage(content: SFImage?) -> some View {
        if let content {
            self.draggable(content)
        }else {
            self
        }
    }
    
    /// 拖拽接收 Text 内容
    func onDropText(textReceive: @escaping (String) -> Void) -> some View {
        self.onDrop(of: [UTType.utf8PlainText.identifier, UTType.utf16PlainText.identifier],
                    isTargeted: nil,
                    perform: {
            providers in
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
        })
    }
    
    /// 拖拽接收 Image 内容
    func onDropImage(imageReceive: @escaping (SFImage) -> Void) -> some View {
        self.onDrop(of: [UTType.image.identifier], isTargeted: nil, perform: { providers in
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
