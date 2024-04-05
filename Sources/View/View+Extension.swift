//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI

public enum AmosError: Error, Equatable, LocalizedError {
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg
        }
    }
}

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
}

#if !os(watchOS)
@available(iOS 16, macOS 13, watchOS 9, *)
public struct SimpleTextField<Menus: View>: View {
    @State private var isTargeted: Bool = false
    @Binding var inputText: String
    let prompt: String
    let startLine: Int
    let endLine: Int
    let tintColor: Color
    let canClear: Bool
    let moreMenus: () -> Menus
    
    public init(_ inputText: Binding<String>,
         prompt: String = "请输入文本",
         startLine: Int = 5,
         endLine: Int = 12,
         tintColor: Color,
         canClear: Bool = true,
         @ViewBuilder moreMenus: @escaping () -> Menus = { EmptyView() }) {
        self._inputText = inputText
        self.prompt = prompt
        self.startLine = startLine
        self.endLine = endLine
        self.tintColor = tintColor
        self.canClear = canClear
        self.moreMenus = moreMenus
    }
    
    public var body: some View {
        TextField("请输入文本",
                  text: $inputText,
                  prompt: Text(prompt),
                  axis: .vertical)
        .lineLimit(startLine...endLine)
        .lineSpacing(4)
        .font(.body)
        .scrollDismissesKeyboard(.automatic)
        .textFieldStyle(.plain)
        .tint(tintColor)
        .padding(.bottom, 28)
        .onDrop(of: ["public.text"], isTargeted: $isTargeted, perform: { providers in
            return true
        })
        .overlay(alignment: .bottomTrailing) {
            Menu {
                moreMenus()
            } label: {
                HStack(spacing: 4) {
                    Text("\(inputText.count) 字")
                        .font(.footnote)
                    if !inputText.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.small)
                            .opacity(0.9)
                    }
                }
                .foregroundColor(.white)
                .padding(.vertical, 2.6)
                .padding(.horizontal, 6)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(.secondary)
                        .opacity(0.5)
                }
            } primaryAction: {
                inputText = ""
            }
            .buttonStyle(.plain)
            .disabled(!canClear)
        }
    }
}
#endif
