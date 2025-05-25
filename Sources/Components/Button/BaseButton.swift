//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

/// 简单的确认用的按钮（默认Title是确认）
public struct BaseButton<V: View, S: PrimitiveButtonStyle>: View {
    let title: String?
    let systemImage: String?
    let imageBgColor: Color?
    let role: ButtonRole?
    let style: S
    let bundle: Bundle
    
    let isInMiddle: Bool
    let isLoading: Bool
    
    /// 自定义的视图无视居中属性
    @ViewBuilder var label: () -> V
    let action: () -> Void
    
    public init(
        title: String? = .confirm,
        systemImage: String? = nil,
        imageBgColor: Color? = nil,
        role: ButtonRole? = nil,
        style: S = .borderless,
        bundle: Bundle = .main,
        isInMiddle: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void,
        label: @escaping () -> V = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.imageBgColor = imageBgColor
        self.role = role
        self.style = style
        self.bundle = bundle
        self.isInMiddle = isInMiddle
        self.isLoading = isLoading
        self.label = label
        self.action = action
    }
    
    public var body: some View {
        Button(role: role, action: action, label: {
            if V.self != EmptyView.self {
                label()
                    .contentShape(Rectangle())
            } else {
                if isInMiddle {
                    HStack {
                        Spacer()
                        labelView()
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }else {
                    HStack {
                        labelView()
                        Spacer()
                    }
                        .contentShape(Rectangle())
                }
            }
        })
        .buttonStyle(style)
    }
    
    private func labelView() -> some View {
        HStack {
            if isLoading {
                ProgressView()
            }else if let systemImage {
                if let imageBgColor {
                    ZStack {
                        Circle()
                            .foregroundStyle(imageBgColor.opacity(0.3))
                            #if os(macOS)
                            .frame(width: 22, height: 22)
                            #else
                            .frame(width: 26, height: 26)
                            #endif
                        Circle()
                            .foregroundStyle(.regularMaterial)
                            #if os(macOS)
                                .frame(width: 22, height: 22)
                            #else
                                .frame(width: 26, height: 26)
                            #endif
                        Image(systemName: systemImage)
                            .imageScale(.medium)
                    }
                    .compositingGroup()
                }else {
                    Image(systemName: systemImage)
                }
            }
            if let title {
                Text(title.toLocalizedKey(), bundle: bundle)
            }
        }
    }
}

#if !os(watchOS)
struct ButtonShortkey: ViewModifier {
    let role: ButtonRole?
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    
    func body(content: Content) -> some View {
        if role == .cancel {
            content
                .simpleKeyboard(.escape)
        }else if let key {
            content
                .keyboardShortcut(key, modifiers: modifiers ?? [])
        }else {
            content
        }
    }
}
#endif

#Preview {
    DemoCommonButton()
}
