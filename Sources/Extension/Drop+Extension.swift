//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/2/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

#if !os(watchOS)

// 拖拽内容 Drop
public extension View {
    /// 允许拖拽文字
    @ViewBuilder func dragText(content: String?) -> some View {
        if let content {
            self.draggable(content)
        }else {
            self
        }
    }
    
    /// 允许拖拽图片
    /// 必须直接附在图片下方（不能在 Button、Menu 下方）
    @ViewBuilder func dragImage(image: SFImage?) -> some View {
        if let image {
            self.draggable(image)
        }else {
            self
        }
    }
    
    /// 拖拽接收 Text 内容
    func onDropText(
        isTargeted: Binding<Bool>? = nil,
        textReceive: @escaping (String) -> Void
    ) -> some View {
        self
            .onDrop(
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
        self.onDrop(
            of: [.image, .png, .jpeg, .heic],
            isTargeted: isTargeted,
            perform: { providers in
                if let provider = providers.first {
                    provider.loadDataRepresentation(
                        forTypeIdentifier: UTType.image.identifier
                    ) { (data, error) in
                        if let data,
                           let image = SFImage(data: data) {
                        debugPrint("接收到了图片：\(data.count.toDouble.toStorage())")
                        imageReceive(image)
                    }
                }
            }
            return false
        })
    }
    
    /// 拖拽接收文件内容
    func onDropFile(
        types: [UTType],
        isTargeted: Binding<Bool>? = nil,
        fileReceive: @escaping (Data) -> Void
    ) -> some View {
        self.onDrop(
            of: types,
            isTargeted: isTargeted,
            perform: { providers in
                if let provider = providers.first {
                    provider.loadDataRepresentation(
                        forTypeIdentifier: UTType.image.identifier
                    ) { (data, error) in
                        if let data {
                        debugPrint("接收到了文件：\(data.count.toDouble.toStorage())")
                        fileReceive(data)
                    }
                }
            }
            return false
        })
    }
}
#endif
