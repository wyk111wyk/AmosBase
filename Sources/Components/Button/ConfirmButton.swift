//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

/// 简单的确认用的按钮（默认Title是确认）
public struct SimpleConfirmButton<V: View>: View {
    let title: String?
    let systemImage: String?
    let role: ButtonRole?
    
    @ViewBuilder var label: () -> V
    let action: () -> Void
    
    public init(
        title: String? = "Confirm",
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void,
        label: @escaping () -> V = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.label = label
        self.action = action
    }
    
    public var body: some View {
        Button(role: role, action: action, label: {
            if V.self != EmptyView.self {
                label()
            } else {
                HStack {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    if let title {
                        Text(title.localized())
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
        })
        .buttonStyle(.borderless)
    }
}

struct ButtonShortkey: ViewModifier {
    let role: ButtonRole?
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    
    func body(content: Content) -> some View {
        if role == .cancel {
            content
                .simpleKeyboard(.escape)
        }else if let key, let modifiers {
            content
                .simpleKeyboard(key, modifiers: modifiers)
        }else {
            content
        }
    }
}
