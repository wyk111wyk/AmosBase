//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

/// 简单UI组件 -  文字居中的按钮
///
/// 可定制按钮类型，文字颜色为app主要色
public struct SimpleMiddleButton<S : PrimitiveButtonStyle>: View {
    let title: LocalizedStringKey
    let systemImageName: String?
    let isLoading: Bool
    let role: ButtonRole?
    let style: S
    let rowVisibility: Visibility
    let bundle: Bundle
    
    let action: () -> Void
    
    #if os(watchOS)
    public init(
        _ title: LocalizedStringKey,
        systemImageName: String? = nil,
        isLoading: Bool = false,
        role: ButtonRole? = nil,
        style: S = .plain,
        rowVisibility: Visibility = .hidden,
        bundle: Bundle = .main,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImageName = systemImageName
        self.isLoading = isLoading
        self.role = role
        self.style = style
        
        self.rowVisibility = rowVisibility
        self.bundle = bundle
        self.action = action
    }
    #else
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    public init(
        _ title: LocalizedStringKey,
        systemImageName: String? = nil,
        isLoading: Bool = false,
        role: ButtonRole? = nil,
        style: S = .borderless,
        rowVisibility: Visibility = .hidden,
        bundle: Bundle = .main,
        key: KeyEquivalent? = nil,
        modifiers: EventModifiers? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImageName = systemImageName
        self.isLoading = isLoading
        self.role = role
        self.style = style
        
        self.bundle = bundle
        self.rowVisibility = rowVisibility
        self.key = key
        self.modifiers = modifiers
        self.action = action
    }
    #endif
    
    public var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 8) {
                Spacer()
                if isLoading {
                    ProgressView()
                }else if let systemImageName {
                    Image(systemName: systemImageName)
                }
                Text(title, bundle: bundle)
                Spacer()
            }
        }
        #if !os(watchOS)
        .buttonStyle(style)
        .listRowSeparator(rowVisibility)
        .modifier(
            ButtonShortkey(
                role: role,
                key: key,
                modifiers: modifiers
            )
        )
        #endif
    }
}
