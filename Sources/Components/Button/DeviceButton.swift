//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/30.
//

import SwiftUI

/// 不同设备不同的按钮样式
/// macOS: bordered 默认样式
/// iOS: borderless 自定义样式
public struct DeviceButton<
    S: PrimitiveButtonStyle,
    MS: PrimitiveButtonStyle,
    V: View
>: View {
    let phoneStyle: S
    let macStyle: MS
    
    let label: () -> V
    let tapAction: () -> Void
    
    public init(
        phoneStyle: S = .borderless,
        macStyle: MS = .bordered,
        tapAction: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> V
    ) {
        self.phoneStyle = phoneStyle
        self.macStyle = macStyle
        self.label = label
        self.tapAction = tapAction
    }
    
    public var body: some View {
        Button(action: tapAction, label: label)
            #if os(macOS)
            .buttonStyle(macStyle)
            #else
            .buttonStyle(phoneStyle)
            #endif
    }
}
